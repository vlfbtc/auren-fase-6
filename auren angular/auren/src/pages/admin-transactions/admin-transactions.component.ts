import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TransactionsService } from '../../core/transactions.service';
import { Transaction, TransactionCreate } from '../../models/transaction.model';
import { TransactionFormComponent, TxEditable } from './transaction-form.component';

@Component({
  standalone: true,
  selector: 'app-admin-transactions',
  imports: [CommonModule, FormsModule, TransactionFormComponent],
  templateUrl: './admin-transactions.component.html',
  styleUrls: ['./admin-transactions.component.scss'],
})
export class AdminTransactionsComponent implements OnInit {
  private tx = inject(TransactionsService);
  private cdr = inject(ChangeDetectorRef);

  list: Transaction[] = [];
  loading = false;
  error = '';
  from: string = this.getDate(-7);
  to: string = this.getDate(0);
  limit = 50;

  editing: TxEditable | null = null;

  ngOnInit(): void { this.load(); }

  getDate(offset: number): string {
    const d = new Date();
    d.setDate(d.getDate() + offset);
    return d.toISOString().slice(0, 10);
  }

  load() {
    this.loading = true;
    this.tx.list(this.from, this.to, this.limit).subscribe({
      next: (arr) => {
        console.log('[AdminTransactions] Transações recebidas:', arr);
        this.list = arr;
        this.loading = false;
        setTimeout(() => this.cdr.detectChanges());
      },
      error: (e) => { this.error = e?.error || String(e); this.loading = false; setTimeout(() => this.cdr.detectChanges()); }
    });
  }

  new() {
    this.editing = {
      description: '',
      type: 'EXPENSE',
      amount: 0,
      date: new Date().toISOString().slice(0,10),
      category: 'Outros',
    };
  }

  edit(row: Transaction) { this.editing = { ...row }; }
  cancel() { this.editing = null; }

  save(tx: TxEditable) {
    if (!tx.id) {
      this.tx.create(tx).subscribe({
        next: (created) => {
          console.log('[AdminTransactions] Transação criada:', created);
          setTimeout(() => {
            this.editing = null;
            this.load();
          });
        },
        error: (e) => alert('Falha ao criar: ' + (e?.error || e))
      });
    } else {
      const { id, ...rest } = tx;
      this.tx.update(id!, rest as TransactionCreate).subscribe({
        next: (updated) => {
          console.log('[AdminTransactions] Transação editada:', updated);
          setTimeout(() => {
            this.editing = null;
            this.load();
          });
        },
        error: (e) => alert('Falha ao atualizar: ' + (e?.error || e))
      });
    }
  }

  remove(row: Transaction) {
    if (!confirm('Excluir esta transação?')) return;
    this.tx.remove(row.id).subscribe({
      next: () => {
        console.log('[AdminTransactions] Transação removida:', row.id);
        this.load();
      },
      error: (e) => alert('Falha ao excluir: ' + (e?.error || e))
    });
  }
}
