import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '../environments/environment';
import { AuthService } from './auth.service';
import { Transaction, TransactionCreate } from '../models/transaction.model';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class TransactionsService {
  private http = inject(HttpClient);
  private auth = inject(AuthService);
  private base = environment.apiBase;

  list(from?: string, to?: string, limit = 50): Observable<Transaction[]> {
    const uid = this.auth.userId();
    let params = new HttpParams();
    if (from) params = params.set('from', from);
    if (to) params = params.set('to', to);
    if (limit) params = params.set('limit', String(limit));
    return this.http.get<Transaction[]>(
      `${this.base}/users/${uid}/transactions`, { params }
    );
  }

  create(tx: TransactionCreate) {
    const uid = this.auth.userId();
    return this.http.post<Transaction>(`${this.base}/users/${uid}/transactions`, tx);
  }

  update(id: number, tx: TransactionCreate) {
    const uid = this.auth.userId();
    return this.http.put<Transaction>(`${this.base}/users/${uid}/transactions/${id}`, tx);
  }

  remove(id: number) {
    const uid = this.auth.userId();
    return this.http.delete<void>(`${this.base}/users/${uid}/transactions/${id}`);
  }
}
