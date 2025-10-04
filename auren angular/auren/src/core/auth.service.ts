import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { SafeStorage } from './safe-storage.service';

const API = 'http://localhost:8080/api/v1';

export type LoginResp = {
  accessToken: string;
  userId: number;
  refreshToken?: string;
};

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private store = inject(SafeStorage);

  login(email: string, password: string): Observable<LoginResp> {
    return this.http.post<LoginResp>(`${API}/auth/login`, { email, password });
  }

  saveSession(r: LoginResp): void {
    this.store.set('accessToken', r.accessToken);
    this.store.set('userId', String(r.userId));
    if (r.refreshToken) this.store.set('refreshToken', r.refreshToken);
  }

  logout(): void {
    this.store.remove('accessToken');
    this.store.remove('refreshToken');
    this.store.remove('userId');
  }

  isLogged(): boolean {
    return !!this.store.get('accessToken');
  }

  userId(): number | null {
    const v = this.store.get('userId');
    return v ? +v : null;
  }

  token(): string | null {
    return this.store.get('accessToken');
  }
}
