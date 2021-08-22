from rest_framework import serializers
from core.models import Reward
from core.models import Event
from core.models import HashtagHashtags
from core.models import Hashtag
from core.models import JoinUser
from core.models import JoinPost


class HashtagHashtagsSerializer(serializers.ModelSerializer):
    class Meta:
        model = HashtagHashtags
        fields = ['hashtags']


class HashtagSerializer(serializers.ModelSerializer):
    hashtag_hashtags = HashtagHashtagsSerializer(many=True)

    class Meta:
        model = Hashtag
        fields = ['hashtag_hashtags']


class RewardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reward
        fields = ['id', 'count', 'level', 'used_count']


class EventSerializer(serializers.ModelSerializer):
    hashtag = HashtagSerializer()
    rewards = RewardSerializer(many=True)

    class Meta:
        model = Event
        fields = ['hashtag', 'rewards']


class EventHashtagSerializer(serializers.ModelSerializer):
    hashtag = HashtagSerializer()

    class Meta:
        model = Event
        fields = '__all__'


class ThisJoinSerializer(serializers.ModelSerializer):
    reward = RewardSerializer()
    event = EventSerializer()

    class Meta:
        model = JoinPost
        fields = [
            'id',
            'reward',
            'event',
            'sns_id',
            'type',
            'status',
            'like_count',
            'comment_count',
            'hashtags',
            'upload_date',
            'private_date',
            'delete_date',
        ]

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        try:
            join_user = JoinUser.objects.get(sns_id=representation['sns_id'], type=representation['type'])
        except JoinUser.DoesNotExist:
            join_user = {
                'follow_count': 0,
            }
        join_user_serializer = JoinUserSerializer(join_user)
        representation['join_user'] = join_user_serializer.data

        try:
            prev_posts = JoinPost.objects.filter(sns_id=representation['sns_id'], type=representation['type'])
        except JoinPost.DoesNotExist:
            prev_posts = []
        prev_posts_serializer = JoinPostSerializer(data=prev_posts, many=True)
        prev_posts_serializer.is_valid()

        like_count, comment_count = 0, 0
        for prev_post in prev_posts_serializer.data:
            like_count += prev_post['like_count']
            comment_count += prev_post['comment_count']

        representation['prev_posts'] = {
            'like_count': like_count,
            'comment_count': comment_count,
        }

        hashtags = []
        for hashtag_hashtag in representation['event']['hashtag']['hashtag_hashtags']:
            hashtags.append(hashtag_hashtag['hashtags'])

        representation['event']['hashtag'] = hashtags
        return representation


class OtherJoinSerializer(ThisJoinSerializer):
    reward = None

    class Meta:
        model = JoinPost
        exclude = ['reward']


class JoinPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = JoinPost
        fields = '__all__'


class JoinUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = JoinUser
        fields = '__all__'