import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '../environments/environment';
import { AuthService } from './auth.service';
import { InsightsBundle } from '../models/insights.model';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class InsightsService {
  private http = inject(HttpClient);
  private auth = inject(AuthService);
  private base = environment.apiBase;

  // versão com params (months/topN/refresh)
  getInsights(months = 6, topN = 10, refresh = false): Observable<InsightsBundle> {
    const id = this.auth.userId();
    let params = new HttpParams()
      .set('months', String(months))
      .set('topN', String(topN));
    if (refresh) params = params.set('refresh', 'true');

    return this.http.get<InsightsBundle>(`${this.base}/users/${id}/insights`, { params });
  }

  get(): Observable<InsightsBundle> {
    return this.getInsights();
  }
}