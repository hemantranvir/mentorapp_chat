# Generated by Django 1.10.5 on 2017-03-09 05:23
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("zerver", "0076_userprofile_emojiset"),
    ]

    operations = [
        migrations.AddField(
            model_name="realmemoji",
            name="file_name",
            field=models.TextField(db_index=True, null=True),
        ),
        migrations.RemoveField(
            model_name="realmemoji",
            name="img_url",
        ),
    ]