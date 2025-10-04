import { Component, OnInit, inject, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { InsightsService } from '../../core/insights.service';
import { InsightsBundle } from '../../models/insights.model';

import { Router, NavigationEnd } from '@angular/router';
import { Subscription } from 'rxjs';

@Component({
  standalone: true,
  selector: 'app-insights',
  imports: [CommonModule],
  templateUrl: './insights.component.html',
  styleUrls: ['./insights.component.scss']
})
export class InsightsComponent implements OnInit, OnDestroy {
  private ins = inject(InsightsService);
  private router = inject(Router);
  private cdr = inject(ChangeDetectorRef);
  data: InsightsBundle = { tips: [], content: [] };
  loading = false;
  private navSub?: Subscription;

  ngOnInit(): void {
    // Detecta navegação para a rota de insights
    this.navSub = this.router.events.subscribe(event => {
      if (event instanceof NavigationEnd && this.router.url.includes('/insights')) {
        console.log('[Insights] Navegação detectada para /insights, iniciando fetch...');
        this.data = { tips: [], content: [] };
        this.loading = true;
        this.ins.getInsights(6, 10, true).subscribe({
          next: (bundle: InsightsBundle) => {
            console.log('[Insights] Dados recebidos:', bundle);
            this.data = bundle;
            this.loading = false;
            this.cdr.detectChanges();
          },
          error: (err) => {
            console.error('[Insights] Erro ao buscar dados:', err);
            this.data = { tips: [], content: [] };
            this.loading = false;
            this.cdr.detectChanges();
          }
        });
      }
    });
    // Primeira carga
    if (this.router.url.includes('/insights')) {
      console.log('[Insights] Primeira carga da tela de insights, iniciando fetch...');
      this.data = { tips: [], content: [] };
      this.loading = true;
      this.ins.getInsights(6, 10, true).subscribe({
        next: (bundle: InsightsBundle) => {
          console.log('[Insights] Dados recebidos:', bundle);
          this.data = bundle;
          this.loading = false;
          this.cdr.detectChanges();
        },
        error: (err) => {
          console.error('[Insights] Erro ao buscar dados:', err);
          this.data = { tips: [], content: [] };
          this.loading = false;
          this.cdr.detectChanges();
        }
      });
    }
  }

  ngOnDestroy(): void {
    this.navSub?.unsubscribe();
  }

  refresh() {
    console.log('[Insights] Refresh acionado, iniciando fetch...');
    this.loading = true;
    this.ins.getInsights(6, 10, true).subscribe({
      next: (bundle: InsightsBundle) => {
        console.log('[Insights] Dados recebidos (refresh):', bundle);
        this.data = bundle;
        this.loading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('[Insights] Erro ao buscar dados (refresh):', err);
        this.data = { tips: [], content: [] };
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  open(url: string) {
    window.open(url, '_blank');
  }
}
