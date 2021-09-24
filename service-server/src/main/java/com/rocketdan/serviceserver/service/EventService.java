package com.rocketdan.serviceserver.service;

import com.rocketdan.serviceserver.Exception.resource.InvalidRequestBodyException;
import com.rocketdan.serviceserver.Exception.resource.NoAuthorityToResourceException;
import com.rocketdan.serviceserver.app.dto.event.EventListResponseDto;
import com.rocketdan.serviceserver.app.dto.event.EventResponseDto;
import com.rocketdan.serviceserver.app.dto.event.EventStatusUpdateRequest;
import com.rocketdan.serviceserver.app.dto.event.hashtag.HashtagEventResponseDto;
import com.rocketdan.serviceserver.app.dto.event.hashtag.HashtagEventSaveRequest;
import com.rocketdan.serviceserver.app.dto.event.hashtag.HashtagEventUpdateRequest;
import com.rocketdan.serviceserver.app.dto.reward.RewardResponseDto;
import com.rocketdan.serviceserver.config.auth.UserIdValidCheck;
import com.rocketdan.serviceserver.domain.event.Event;
import com.rocketdan.serviceserver.domain.event.EventRepository;
import com.rocketdan.serviceserver.domain.event.type.Hashtag;
import com.rocketdan.serviceserver.domain.store.Store;
import com.rocketdan.serviceserver.domain.store.StoreRepository;
import com.rocketdan.serviceserver.s3.service.UpdateImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RequiredArgsConstructor
@Service
public class EventService {
    private final EventRepository eventRepository;
    private final StoreRepository storeRepository;

    private final UpdateImageService updateImageService;

    private final UserIdValidCheck userIdValidCheck;

    @Transactional
    public Long saveHashtagEvent(Long store_id, HashtagEventSaveRequest requestDto, org.springframework.security.core.userdetails.User principal) throws NoAuthorityToResourceException {
        Store linkedStore = storeRepository.findById(store_id).orElseThrow(() -> new IllegalArgumentException("해당 가게가 없습니다. id=" + store_id));

        // valid 하지 않으면 exception 발생
        userIdValidCheck.userIdValidCheck(linkedStore.getUser().getUserId(), principal);

        // status valid check
        if (!checkDateValid(requestDto.getStartDate(), requestDto.getFinishDate())) {
            throw new InvalidRequestBodyException("Invalid date.");
        }
        System.out.println(requestDto.getStartDate() + " " + requestDto.getFinishDate());

        // 이미지
        List<String> imgPaths = updateImageService.uploadNewImages(requestDto.getImages(), "image/event");

        Event savedEvent = requestDto.toEntity(imgPaths);

        // link store
        savedEvent.setStore(linkedStore);

        // status update
        savedEvent.updateStatus();

        return eventRepository.save(savedEvent).getId();
    }

    @Transactional
    public Long updateHashtagEvent(Long id, HashtagEventUpdateRequest requestDto, org.springframework.security.core.userdetails.User principal) throws NoAuthorityToResourceException {
        Hashtag event = (Hashtag) eventRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("해당 이벤트가 없습니다. id=" + id));

        // valid 하지 않으면 exception 발생
        userIdValidCheck.userIdValidCheck(event.getStore().getUser().getUserId(), principal);

        // 이미지
        List<String> imgPaths = updateImageService.uploadNewImages(requestDto.getNewImages(), "image/event");
        List<String> filteredImgPaths = updateImageService.deleteImagePaths(event.getImagePaths(), requestDto.getDeleteImagePaths());

        imgPaths.addAll(filteredImgPaths);

        event.update(requestDto.getTitle(), requestDto.getStartDate(), requestDto.getFinishDate(), imgPaths,
                requestDto.getHashtags(), requestDto.getRequirements(), requestDto.getTemplate());

        // status update
        event.updateStatus();

        return id;
    }

    private boolean checkDateValid(LocalDateTime startDate, LocalDateTime finishDate) {
        LocalDate now = LocalDate.now();
        boolean startDateValid = now.compareTo(startDate.toLocalDate()) <= 0;
        boolean finishDateValid = true;
        if (Optional.ofNullable(finishDate).isPresent()) {
            finishDateValid = startDate.isBefore(finishDate);
        }
        return startDateValid && finishDateValid;
    }

    @Transactional
    public void updateStatus(Long id, EventStatusUpdateRequest requestDto, org.springframework.security.core.userdetails.User principal) throws NoAuthorityToResourceException {
        Event event = eventRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("해당 이벤트가 없습니다. id=" + id));

        // valid 하지 않으면 exception 발생
        userIdValidCheck.userIdValidCheck(event.getStore().getUser().getUserId(), principal);

        event.updateStatus(requestDto.getStatus());
    }

    @Transactional(readOnly = true)
    public EventResponseDto findById(Long id) {
        Event entity = eventRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("해당 이벤트가 없습니다. id=" + id));
        entity.updateStatus();

        if (entity.getType().equals("hashtag")) {
            return new HashtagEventResponseDto((Hashtag) entity);
        }

        return new EventResponseDto(entity);
    }

    @Transactional(readOnly = true)
    public List<EventListResponseDto> findAll() {
        return eventRepository.findAll().stream()
                // 람다식 사용. 실제 코드 : .map(posts -> new PostsListResponseDto(posts))
                // eventRepository 결과로 넘어온 Event의 Stream을 map울 통해 EventListResponseDto 변환 -> List로 반환하는 메소드
                .map(EventListResponseDto::new)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RewardResponseDto> getRewardListById(Long id) {
        Event entity = eventRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("해당 이벤트가 없습니다. id=" + id));
        return entity.getRewards().stream()
                .map(RewardResponseDto::new)
                .collect(Collectors.toList());
    }

    @Transactional
    public void softDelete(Long id, org.springframework.security.core.userdetails.User principal) throws NoAuthorityToResourceException  {
        Event event = eventRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("해당 이벤트가 없습니다. id=" + id));

        // valid 하지 않으면 exception 발생
        userIdValidCheck.userIdValidCheck(event.getStore().getUser().getUserId(), principal);

        // 이미지 S3에서 삭제
        updateImageService.deleteImagePaths(event.getImagePaths());

        eventRepository.delete(event);
    }
}
