import { Component, OnInit, inject, ChangeDetectorRef, ApplicationRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TransactionsService } from '../../core/transactions.service';
import { InsightsService } from '../../core/insights.service';
import { Transaction } from '../../models/transaction.model';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartType } from 'chart.js';

@Component({
  standalone: true,
  selector: 'app-home',
  imports: [CommonModule, NgChartsModule],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  private tx = inject(TransactionsService);
  private insights = inject(InsightsService);
  private cdr = inject(ChangeDetectorRef);
  private appRef = inject(ApplicationRef);

  loading = false;
  error = '';
  list: Transaction[] = [];
  tips: { title: string; description: string }[] = [];

  // Gráficos
  incomeBarData: ChartConfiguration<'bar'>['data'] = { labels: [], datasets: [] };
  expensePieData: ChartConfiguration<'pie'>['data'] = { labels: [], datasets: [] };

  // Datas padrão igual à tela de transações
  from: string = this.getDate(-7);
  to: string = this.getDate(0);
  limit = 50;

  getDate(offset: number): string {
    const d = new Date();
    d.setDate(d.getDate() + offset);
    return d.toISOString().slice(0, 10);
  }

  ngOnInit(): void {
    // Só chama load se o usuário estiver autenticado
    if (this.tx['auth'].isLogged()) {
      this.load();
    }
  }

  private buildCharts(transactions: Transaction[]) {
    // Gráfico de barras: renda por data
    const income = transactions.filter(t => t.type === 'INCOME');
    const incomeByDate: { [date: string]: number } = {};
    income.forEach(t => {
      incomeByDate[t.date] = (incomeByDate[t.date] || 0) + t.amount;
    });
    this.incomeBarData = {
      labels: Object.keys(incomeByDate),
      datasets: [{
        data: Object.values(incomeByDate),
        label: 'Renda',
        backgroundColor: '#22c55e',
      }]
    };

    // Gráfico de pizza: despesas por categoria (sempre pie, mesmo 1 categoria)
    const expense = transactions.filter(t => t.type === 'EXPENSE');
    const allCategories = Array.from(new Set(expense.map(t => t.category)));
    const expenseByCat: { [cat: string]: number } = {};
    allCategories.forEach(cat => { expenseByCat[cat] = 0; });
    expense.forEach(t => {
      expenseByCat[t.category] = (expenseByCat[t.category] || 0) + t.amount;
    });
    this.expensePieData = {
      labels: allCategories,
      datasets: [{
        data: allCategories.map(cat => expenseByCat[cat]),
        backgroundColor: [
          '#f87171', '#fbbf24', '#60a5fa', '#a78bfa', '#34d399', '#f472b6', '#facc15', '#818cf8', '#fb7185', '#38bdf8'
        ],
        label: 'Despesas'
      }]
    };
  }

  load() {
    setTimeout(() => {
      this.loading = true;
      this.cdr.markForCheck();
    });
    this.tx.list(this.from, this.to, this.limit).subscribe({
      next: (arr) => {
        setTimeout(() => {
          this.list = arr.map(t => ({
            id: t.id,
            description: t.description,
            type: t.type,
            amount: t.amount,
            date: t.date,
            category: t.category
          }));
          this.buildCharts(this.list);
          this.loading = false;
          this.cdr.markForCheck();
        });
      },
      error: (e)  => {
        setTimeout(() => {
          this.error = e?.error || String(e);
          this.loading = false;
          this.cdr.markForCheck();
        });
      }
    });

    this.insights.get().subscribe({
      next: (b) => { this.tips = (b.tips || []).slice(0, 2).map(t => ({title: t.title, description: t.description})); this.cdr.detectChanges(); },
      error: () => { this.cdr.detectChanges(); }
    });
  }
}
