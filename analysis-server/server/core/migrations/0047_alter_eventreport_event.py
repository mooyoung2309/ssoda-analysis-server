# Generated by Django 3.2.5 on 2021-10-16 14:44

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0046_auto_20211016_1443'),
    ]

    operations = [
        migrations.AlterField(
            model_name='eventreport',
            name='event',
            field=models.OneToOneField(on_delete=django.db.models.deletion.DO_NOTHING, related_name='report_event', to='core.event'),
        ),
    ]