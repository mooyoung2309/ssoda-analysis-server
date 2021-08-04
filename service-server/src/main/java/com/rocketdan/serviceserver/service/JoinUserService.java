package com.rocketdan.serviceserver.service;

import com.rocketdan.serviceserver.Exception.JoinEventFailedException;
import com.rocketdan.serviceserver.core.CommonResponse;
import com.rocketdan.serviceserver.domain.join.post.JoinPost;
import com.rocketdan.serviceserver.domain.join.post.JoinPostRepository;
import com.rocketdan.serviceserver.domain.join.user.JoinUser;
import com.rocketdan.serviceserver.domain.join.user.JoinUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Date;
import java.util.Optional;

@RequiredArgsConstructor
@Service
public class JoinUserService {
    private final JoinUserRepository joinUserRepository;
    private final JoinPostRepository joinPostRepository;

    private WebClient webClient = WebClient.builder()
            .baseUrl("http://54.180.141.90:8080/api/v1/join/user")
            .build();

    @Transactional
    public Long save(Long joinPostId) {
        JoinPost linkedJoinPost = joinPostRepository.findById(joinPostId).orElseThrow(() -> new IllegalArgumentException("해당 게시글이 없습니다. id=" + joinPostId));

        // 같은 snsId, type을 가진 join user 가 존재할 경우 저장하지 않고 리턴
        Optional<JoinUser> joinUser = joinUserRepository.findBySnsIdAndType(linkedJoinPost.getSnsId(), linkedJoinPost.getType());
        if (joinUser.isPresent()) {
            return joinUser.get().getId();
        }

        JoinUser savedJoinUser = JoinUser.builder()
                .snsId(linkedJoinPost.getSnsId())
                .type(linkedJoinPost.getType())
                .createDate(new Date())
                .build();

        return joinUserRepository.save(savedJoinUser).getId();
    }

    // analysis-server에 put 요청
    public void putJoinUser(Long joinUserId) {
        webClient.put() // PUT method
                .uri("/" + joinUserId) // baseUrl 이후 uri
//                .bodyValue(bodyEmpInfo) // set body value
                .retrieve() // client message 전송
                .onStatus(HttpStatus::is4xxClientError, clientResponse -> Mono.error(JoinEventFailedException::new));
//                .bodyToMono(CommonResponse.class) // body type
//                .block(); // await
    }
    /*
    public CommonResponse putJoinUser(Long joinUserId) {
        return webClient.put() // PUT method
                .uri("/api/v1/join/user/" + joinUserId) // baseUrl 이후 uri
//                .bodyValue(bodyEmpInfo) // set body value
                .retrieve() // client message 전송
                .onStatus(HttpStatus::is4xxClientError, clientResponse -> Mono.error(JoinEventFailedException::new))
                .bodyToMono(CommonResponse.class) // body type
                .block(); // await
    }
    */
}
