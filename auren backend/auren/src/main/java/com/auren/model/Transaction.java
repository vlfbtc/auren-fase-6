package com.auren.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "transactions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Oracle 12c+ suporta IDENTITY
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id") // FK -> users.id
    private User user;

    @Column(nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "tx_type", nullable = false) // coluna Oracle
    private TransactionType type; // INCOME ou EXPENSE

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount; // sempre POSITIVO

    @Column(name = "tx_date", nullable = false) // coluna Oracle
    private LocalDate date;

    @Column(nullable = false)
    private String category; // lazer, moradia, educação etc
}
