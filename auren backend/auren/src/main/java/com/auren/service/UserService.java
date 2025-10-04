package com.auren.service;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.auren.model.User;
import com.auren.repository.UserRepository;
import com.auren.security.UserPrincipal;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {

    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        var u = userRepo.findByEmail(email.toLowerCase())
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado"));
        return new UserPrincipal(u);
    }

    public UserPrincipal loadPrincipalById(Long id) {
        var u = userRepo.findById(id).orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado"));
        return new UserPrincipal(u);
    }

    public User createUser(String first, String last, String email, java.time.LocalDate birth, String rawPassword) {
        if (userRepo.existsByEmail(email.toLowerCase())) {
            throw new IllegalArgumentException("E-mail já cadastrado");
        }
        var user = User.builder()
                .firstName(first)
                .lastName(last)
                .email(email.toLowerCase())
                .birthDate(birth)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .role("USER")
                .build();
        return userRepo.save(user);
    }

    public User findById(Long id) {
        return userRepo.findById(id).orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado"));
    }

    public User findByEmail(String email) {
        return userRepo.findByEmail(email.toLowerCase()).orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado"));
    }

    public boolean checkPassword(User user, String raw) {
        return passwordEncoder.matches(raw, user.getPasswordHash());
    }
}
