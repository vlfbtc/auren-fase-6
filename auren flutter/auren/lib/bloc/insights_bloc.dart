import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:auren/features/auth/data/repositories/insights_repository.dart';
import 'package:auren/features/auth/data/datasources/financial_education_service.dart'
    show FinancialTip, EducationalContentItem;

//
// Events
//
abstract class InsightsEvent extends Equatable {
  const InsightsEvent();
  @override
  List<Object?> get props => [];
}

class LoadInsights extends InsightsEvent {
  const LoadInsights();
}

class GenerateInsights extends InsightsEvent {
  const GenerateInsights();
}

//
// States
//
abstract class InsightsState extends Equatable {
  const InsightsState();
  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

class InsightsLoaded extends InsightsState {
  final List<FinancialTip> tips;
  final List<EducationalContentItem> edu;
  const InsightsLoaded({required this.tips, required this.edu});

  @override
  List<Object?> get props => [tips, edu];
}

class InsightsError extends InsightsState {
  final String message;
  const InsightsError(this.message);
  @override
  List<Object?> get props => [message];
}

//
// Bloc
//
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final InsightsRepository repo;

  InsightsBloc({required this.repo}) : super(const InsightsInitial()) {
    on<LoadInsights>(_onLoad);
    on<GenerateInsights>(_onGenerate);
  }

  Future<void> _onLoad(LoadInsights e, Emitter<InsightsState> emit) async {
    emit(const InsightsLoading());
    try {
      final r = await repo.recent();
      emit(InsightsLoaded(tips: r.tips, edu: r.edu));
    } catch (err) {
      debugPrint('LoadInsights error: $err');
      emit(InsightsError(err.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onGenerate(GenerateInsights e, Emitter<InsightsState> emit) async {
    emit(const InsightsLoading());
    try {
      final r = await repo.generate();
      emit(InsightsLoaded(tips: r.tips, edu: r.edu));
    } catch (err) {
      debugPrint('GenerateInsights error: $err');
      emit(InsightsError(err.toString().replaceFirst('Exception: ', '')));
    }
  }
}
