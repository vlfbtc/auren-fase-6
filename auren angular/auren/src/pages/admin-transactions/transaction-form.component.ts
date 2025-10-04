import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TransactionCreate, TxType } from '../../models/transaction.model';

export type TxEditable = TransactionCreate & { id?: number };

@Component({
  standalone: true,
  selector: 'app-transaction-form',
  imports: [CommonModule, FormsModule],
  templateUrl: './transaction-form.component.html',
  styleUrls: ['./transaction-form.component.scss'],
})
export class TransactionFormComponent {
  form: TxEditable | null = null;

  private _model: TxEditable | null = null;
  @Input()
  get model(): TxEditable | null { return this._model; }
  set model(v: TxEditable | null) {
    this._model = v;
    this.form = v ? { ...v } : null;
  }

  @Output() save = new EventEmitter<TxEditable>();
  @Output() cancel = new EventEmitter<void>();

  types: TxType[] = ['INCOME', 'EXPENSE'];

  submit() {
    if (this.form) {
      if (this.form.type === 'INCOME') {
        this.form.category = 'Renda';
      }
      this.save.emit(this.form);
      this.form = null;
      this._model = null;
    }
  }

  onCancel() {
    this.cancel.emit();
    this.form = null;
    this._model = null;
  }
}
