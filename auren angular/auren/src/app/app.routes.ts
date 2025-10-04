import { Routes } from '@angular/router';
import { LoginComponent } from '../pages/login/login.component';
import { authGuard } from '../core/auth.guard';

export const routes: Routes = [
  { path: '', component: LoginComponent },
  { path: 'login', component: LoginComponent },
  {
    path: 'home',
    canActivate: [authGuard],
    loadComponent: () => import('../pages/home/home.component').then(m => m.HomeComponent)
  },
  {
    path: 'admin',
    canActivate: [authGuard],
    loadComponent: () => import('../pages/admin-transactions/admin-transactions.component').then(m => m.AdminTransactionsComponent)
  },
  {
    path: 'insights',
    canActivate: [authGuard],
    loadComponent: () => import('../pages/insights/insights.component').then(m => m.InsightsComponent)
  }
];
