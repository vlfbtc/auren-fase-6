package com.auren.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class BcryptOnce {
    public static void main(String[] args) {
        String raw = args.length > 0 ? args[0] : "test123";
        var enc = new BCryptPasswordEncoder(); // custo padrão 10
        String hash = enc.encode(raw);
        System.out.println("RAW: " + raw);
        System.out.println("HASH: " + hash);
    }
}
