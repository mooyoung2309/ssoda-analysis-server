from django.http import JsonResponse, HttpResponse
from django.shortcuts import get_object_or_404, get_list_or_404
from rest_framework.views import APIView
from core.models import JoinPost
from core.models import JoinUser
from .serializers import JoinPostSerializer
from .serializers import JoinUserSerializer
from .serializers import ThisJoinSerializer
from .serializers import OtherJoinSerializer
from core.modules.join.post.post_scraper import PostScraper
from core.modules.join.user.user_scraper import UserScraper
from core.modules.join.reward.reward_calculator import RewardCalculator
from core.exceptions import exceptions
from core.exceptions.exception_parser import parse_exception


# JoinPost PUT 요청
class JoinPostView(APIView):
    def put(self, request, pk):
        # Join Post 가져오기
        join_post = get_object_or_404(JoinPost, pk=pk)
        post_scraper = PostScraper(JoinPostSerializer(join_post).data)
        scraped_post = post_scraper.get_scraped_post()
        join_post_serializer = JoinPostSerializer(join_post, scraped_post, partial=True)
        if join_post_serializer.is_valid():
            join_post_serializer.save()
            raise exceptions.PostUpdateOk
        raise exceptions.PostUpdateFailed


# JoinUser PUT 요청
class JoinUserView(APIView):
    def put(self, request, pk):
        # Join User 가져오기
        join_user = get_object_or_404(JoinUser, pk=pk)
        user_scraper = UserScraper(JoinUserSerializer(join_user).data)
        scraped_user = user_scraper.get_scraped_user()
        join_user_serializer = JoinUserSerializer(join_user, scraped_user, partial=True)
        if join_user_serializer.is_valid():
            join_user_serializer.save()
            raise exceptions.UserUpdateOk
        raise exceptions.UserUpdateFailed


# Reward GET 요청
class JoinRewardView(APIView):
    def get(self, request, pk):
        join_post = get_object_or_404(JoinPost, pk=pk)
        this_join_serializer = ThisJoinSerializer(join_post)
        join_posts = get_list_or_404(JoinPost)
        other_join_serializer = OtherJoinSerializer(data=join_posts, many=True)
        other_join_serializer.is_valid()
        reward_calculator = RewardCalculator(this_join=this_join_serializer.data,
                                             other_joins=other_join_serializer.data)
        this_reward_id = reward_calculator.get_this_reward_id()

        return JsonResponse({'reward_id': this_reward_id})