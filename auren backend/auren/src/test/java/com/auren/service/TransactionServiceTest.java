package com.auren.service;

import com.auren.model.Transaction;
import com.auren.model.TransactionType;
import com.auren.model.User;
import com.auren.model.dto.TransactionRequest;
import com.auren.repository.TransactionRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class TransactionServiceTest {

    @Test
    void create_callsProcedure_whenAboveThreshold() {
        var txRepo = mock(TransactionRepository.class);
        var plsql = mock(OraclePlsqlService.class);

        var service = new TransactionService(txRepo, plsql);

        var user = new User(); user.setId(1L);
        var req = new TransactionRequest();
        req.setDescription("TV");
        req.setType("EXPENSE");
        req.setAmount(new BigDecimal("3500"));
        req.setDate(LocalDate.now());
        req.setCategory("Eletronicos");

        var saved = new Transaction();
        saved.setId(99L);
        saved.setAmount(req.getAmount());
        saved.setType(TransactionType.EXPENSE);

        when(txRepo.save(any(Transaction.class))).thenReturn(saved);

        service.create(user, req);

        ArgumentCaptor<BigDecimal> thr = ArgumentCaptor.forClass(BigDecimal.class);
        verify(plsql, atLeastOnce()).logHighValueTx(eq(99L), thr.capture());
    }

    @Test
    void update_callsProcedure_whenAboveThreshold() {
        var txRepo = mock(TransactionRepository.class);
        var plsql = mock(OraclePlsqlService.class);
        var service = new TransactionService(txRepo, plsql);

        var user = new User(); user.setId(1L);
        var existing = new Transaction();
        existing.setId(10L); existing.setUser(user);

        when(txRepo.findByIdAndUser(10L, user)).thenReturn(Optional.of(existing));
        when(txRepo.save(any(Transaction.class))).thenAnswer(inv -> inv.getArgument(0));

        var req = new TransactionRequest();
        req.setDescription("Notebook");
        req.setType("EXPENSE");
        req.setAmount(new BigDecimal("5000"));
        req.setDate(LocalDate.now());
        req.setCategory("Eletrônicos");

        service.update(user, 10L, req);

        verify(plsql, atLeastOnce()).logHighValueTx(eq(10L), any());
    }
}
