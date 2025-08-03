---
layout: default
---

# Welcome to My Blog

This blog is built with Jekyll and Hugo static site generators for maximum flexibility.

## Recent Posts

{% for post in site.posts limit:5 %}
  <article>
    <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
    <time>{{ post.date | date: "%B %d, %Y" }}</time>
    <p>{{ post.excerpt }}</p>
  </article>
{% endfor %}

[View all posts →](/posts/)
