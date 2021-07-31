package com.rocketdan.serviceserver.app.dto.user;

import com.rocketdan.serviceserver.domain.user.Role;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserResponseDto {
    private String name;
    private String email;
    private Role role;
}
