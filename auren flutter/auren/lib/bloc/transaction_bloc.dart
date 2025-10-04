import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:auren/features/auth/data/repositories/transaction_repository.dart';
import 'package:auren/features/auth/domain/models/transaction.dart';

/// EVENTS
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final int limit;
  const LoadTransactions({this.limit = 10});
  @override
  List<Object?> get props => [limit];
}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  const AddTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

// Opcionalmente, você pode manter estes para o futuro (edição/remoção):
class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction; // deve conter id
  const UpdateTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;
  const DeleteTransactionEvent(this.id);
  @override
  List<Object?> get props => [id];
}

/// STATES
abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionsLoaded extends TransactionState {
  final List<Transaction> transactions;
  const TransactionsLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

/// BLOC
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository txRepo;

  TransactionBloc({required this.txRepo}) : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransactionEvent>(_onAdd);

    // Mantidos para evolução futura
    on<UpdateTransactionEvent>(_onUpdate);
    on<DeleteTransactionEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadTransactions e,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    try {
      final list = await txRepo.fetchTransactions(limit: e.limit);
      emit(TransactionsLoaded(list));
    } catch (ex) {
      emit(TransactionError(
        ex.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAdd(
      AddTransactionEvent e,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    try {
      await txRepo.addTransaction(e.transaction);
      final list = await txRepo.fetchTransactions(limit: 10);
      emit(TransactionsLoaded(list));
    } catch (ex) {
      emit(TransactionError(
        ex.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdate(
      UpdateTransactionEvent e,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    try {
      // Implemente quando tiver endpoints de update:
      // await txRepo.updateTransaction(e.transaction);
      final list = await txRepo.fetchTransactions(limit: 10);
      emit(TransactionsLoaded(list));
    } catch (ex) {
      emit(TransactionError(
        ex.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDelete(
      DeleteTransactionEvent e,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());
    try {
      // Implemente quando tiver endpoints de delete:
      // await txRepo.deleteTransaction(e.id);
      final list = await txRepo.fetchTransactions(limit: 10);
      emit(TransactionsLoaded(list));
    } catch (ex) {
      emit(TransactionError(
        ex.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
