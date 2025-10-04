export type TxType = 'INCOME' | 'EXPENSE';

export interface Transaction {
  id: number;
  description: string;
  type: TxType;
  amount: number;
  date: string;
  category: string;
}

export type TransactionCreate = Omit<Transaction, 'id'>;
