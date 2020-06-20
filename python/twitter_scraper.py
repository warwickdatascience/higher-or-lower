# -*- coding: utf-8 -*-
"""Scrape details from various celebrities' Twitter accounts"""

import json
import re
import shutil

from bs4 import BeautifulSoup
import pandas as pd
import requests
from tqdm import tqdm
import tweepy


def get_celeb_twitters(verbose=True):
    """
    Collect various celebrities' twitter URLs from profilerehab.com.

    Scrapes the contents of profilerehab.com to aquire the twitter URLs of
    several hundred celebrities. The results are returned as a dictionary of
    URLs.

    Args:
        verbose (bool): If `True`, print updates on scraping progress.
    Returns:
        twitter_urls (dict): A dictionary of twitter URLs in which the keys are
                the celebrity names and the values are the corresponding URLs.
    Raises:
        TypeError: If `verbose` is not Boolean
    """
    if not isinstance(verbose, bool):
        raise TypeError("verbose must be Boolean")

    # Get links to category pages
    res = requests.get('http://profilerehab.com/twitter-help/' +
                       'celebrity_twitter_list')
    soup = BeautifulSoup(res.text, features='lxml')
    content = soup.body.find('div', {'class': 'content'})
    a_tags = content.find_all('a')[:9]
    cat_links = {t.text: t['href'] for t in a_tags}

    twitter_urls = {}
    for i, (cat, l) in enumerate(cat_links.items()):
        if verbose:
            print(f"Collecting Twitter Profiles for {cat[:-23]}")
        res = requests.get(l)
        soup = BeautifulSoup(res.text, features='lxml')
        entry = soup.body.find('div', {'id': 'entry'})
        para = entry.find_all('p')
        found = 0
        for p in para:
            if p.find('a', recursive=False) and \
                    p.find('strong', recursive=False):
                # Remove possessive form and question marks
                name = re.sub(r'[\?(?:\'s)]*$', '', p.strong.text.strip())
                twitter_urls[name] = p.a['href']
                found += 1
        if verbose:
            print(f"Found {found} Profiles")
    if verbose:
        print(f"\nTotal Profiles Found: {len(twitter_urls)}\n")

    return twitter_urls


if __name__ == "__main__":
    # Connect to Twitter API
    with open('config.json') as f:
        cfg = json.load(f)
    auth = tweepy.OAuthHandler(*cfg['consumer'].values())
    auth.set_access_token(*cfg['access'].values())
    api = tweepy.API(auth, wait_on_rate_limit=True)

    twitter_urls = get_celeb_twitters()

    # Collect celebrity details
    print("Collecting Details")
    details = {
        'name': [],
        'url': [],
        'uname': [],
        'followers': [],
        'image_path': []
    }
    for i, (name, url) in tqdm(enumerate(twitter_urls.items())):
        uname = re.search('twitter.com/(.*)', url).group(1)
        
        # Special case
        if uname in ('KyleRichards18'):
            continue

        try:
            user = api.get_user(uname)
            details['name'].append(name)
            details['url'].append(url)
            details['uname'].append(uname)
            details['followers'].append(user.followers_count)

            print(uname)
            pp_url = user.profile_image_url.replace('_normal', '')
            print(pp_url)
            pp_type = re.search(r'\.(\w+)$', pp_url).group(1)
            r = requests.get(pp_url, stream=True)
            r.raw.decode_content = True
            with open(f'../www/images/{uname}.{pp_type}', 'wb') as f:
                shutil.copyfileobj(r.raw, f)
            details['image_path'].append(f'images/{uname}.{pp_type}')
        except tweepy.error.TweepError:
            pass

    
    # Write to CSV
    pd.DataFrame(details).to_csv('../resources/twitter_details.csv',
                                 index=False)
