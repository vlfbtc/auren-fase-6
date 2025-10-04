package com.auren.repository;

import com.auren.model.Transaction;
import com.auren.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    // Consulta por entidade User
    List<Transaction> findByUserAndDateBetweenOrderByDateDesc(
            User user,
            LocalDate from,
            LocalDate to
    );

    // Mesma consulta, mas por userId (algum código seu usa esta assinatura)
    List<Transaction> findByUserIdAndDateBetweenOrderByDateDesc(
            Long userId,
            LocalDate from,
            LocalDate to
    );

    // Para update/delete com segurança
    Optional<Transaction> findByIdAndUser(Long id, User user);

    // Amostra “top N” para insights (ex.: últimos 180 registros)
    List<Transaction> findTop180ByUserOrderByDateDesc(User user);
}
