package com.auren.service;

import com.auren.model.Transaction;
import com.auren.model.TransactionType;
import com.auren.model.User;
import com.auren.model.dto.TransactionRequest;
import com.auren.repository.TransactionRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository txRepo;
    private final OraclePlsqlService plsqlService; // <--- NOVO

    private static final BigDecimal ALERT_THRESHOLD = new BigDecimal("1000.00"); // pode virar config

    public List<Transaction> list(User user, LocalDate from, LocalDate to, Integer limit) {
        List<Transaction> list = txRepo.findByUserAndDateBetweenOrderByDateDesc(user, from, to);
        if (limit != null && limit > 0 && list.size() > limit) {
            return list.subList(0, limit);
        }
        return list;
    }

    public Transaction create(User user, TransactionRequest req) {
        if (req.getType() == null) {
            throw new IllegalArgumentException("Tipo da transação é obrigatório (INCOME ou EXPENSE).");
        }
        TransactionType type = TransactionType.valueOf(req.getType().toUpperCase());

        String category = req.getCategory();
        if (type == TransactionType.INCOME && (category == null || category.isBlank())) {
            category = "Renda";
        }
        if (type == TransactionType.EXPENSE && (category == null || category.isBlank())) {
            category = "Outros";
        }

        Transaction tx = Transaction.builder()
                .user(user)
                .description(req.getDescription())
                .type(type)
                .amount(req.getAmount())
                .date(req.getDate())
                .category(category)
                .build();

        tx = txRepo.save(tx);

        // Dispara a procedure de alerta no Oracle (ignora erro para não quebrar fluxo H2/dev)
        try {
            plsqlService.logHighValueTx(tx.getId(), ALERT_THRESHOLD);
        } catch (Exception ignored) {}

        return tx;
    }

    public Transaction update(User user, Long id, TransactionRequest req) {
        Transaction tx = txRepo.findByIdAndUser(id, user)
                .orElseThrow(() -> new EntityNotFoundException("Transação não encontrada"));

        if (req.getType() == null) {
            throw new IllegalArgumentException("Tipo da transação é obrigatório (INCOME ou EXPENSE).");
        }
        TransactionType type = TransactionType.valueOf(req.getType().toUpperCase());

        String category = req.getCategory();
        if (type == TransactionType.INCOME && (category == null || category.isBlank())) {
            category = "Renda";
        }
        if (type == TransactionType.EXPENSE && (category == null || category.isBlank())) {
            category = "Outros";
        }

        tx.setDescription(req.getDescription());
        tx.setType(type);
        tx.setAmount(req.getAmount());
        tx.setDate(req.getDate());
        tx.setCategory(category);

        tx = txRepo.save(tx);

        // Opcional: reavaliar alerta após update
        try {
            plsqlService.logHighValueTx(tx.getId(), ALERT_THRESHOLD);
        } catch (Exception ignored) {}

        return tx;
    }

    public void delete(User user, Long id) {
        Transaction tx = txRepo.findByIdAndUser(id, user)
                .orElseThrow(() -> new EntityNotFoundException("Transação não encontrada"));
        txRepo.delete(tx);
    }

    // Helpers para insights (ex.: últimos 6 meses)
    public List<Transaction> lastMonths(User user, int months) {
        var all = txRepo.findTop180ByUserOrderByDateDesc(user);
        LocalDate cutoff = LocalDate.now().minusMonths(months).withDayOfMonth(1);
        return all.stream()
                .filter(t -> !t.getDate().isBefore(cutoff))
                .sorted(Comparator.comparing(Transaction::getDate).reversed())
                .toList();
    }
}
