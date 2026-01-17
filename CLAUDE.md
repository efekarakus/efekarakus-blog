# CLAUDE.md

## Overview

This is a personal Jekyll blog hosted at https://www.efekarakus.com/. It uses the Minima theme and is deployed to AWS S3 with CloudFront distribution via GitHub Actions.

## Development Commands

### Local Development

Development is done with docker:
```bash
# Build site using Docker (production mode)
make docker-build

# Run local server using Docker (port 4000)
make docker-run
```

## Repository Structure

### Core Jekyll Directories
- `_posts/` - Blog posts in Markdown format with `YYYY-MM-DD-title.md` naming convention
- `_layouts/` - Page templates (default.html, home.html, post.html)
- `_includes/` - Reusable HTML fragments (footer.html, google-analytics.html, label.html)
- `_sass/` - Custom Sass stylesheets
- `_drafts/` - Unpublished draft posts
- `_site/` - Generated static site (excluded from git)

### Configuration
- `_config.yml` - Jekyll site configuration (title, plugins, Google Analytics)
- `Gemfile` - Ruby dependencies including Jekyll and plugins
- `.jekyll-cache/` - Build cache (excluded from git)

### Infrastructure
- `infra/oidc.yaml` - AWS OIDC configuration for GitHub Actions deployment
- `.github/workflows/publish.yaml` - Deployment workflow that builds site and uploads to S3

## Blog Post Format

Posts follow Jekyll's front matter convention:
```yaml
---
layout: post
title: "Your Title"
tagline: "Succinct description of the blog explaining the key point(s) of the post."
tags: [tag1, tag2] # Prefer existing tags when possible.
---
```

Posts are written in Markdown with Kramdown syntax and use Rouge for syntax highlighting.

## Plugins

The site uses the following Jekyll plugins:
- `jekyll-feed` - Generate Atom feed
- `jekyll-seo-tag` - Add SEO meta tags
- `jekyll-last-modified-at` - Track page modification dates
- `jekyll-redirect-from` - Handle URL redirects

## Deployment

Deployment is triggered manually via GitHub Actions workflow dispatch. The workflow:
1. Builds the site using Docker
2. Authenticates to AWS using OIDC
3. Uploads `_site/` contents to S3
4. Invalidates CloudFront cache

Required GitHub secrets: `GH_ACTION_IAM_ROLE_ARN`, `S3_BUCKET_NAME`, `CLOUDFRONT_ID`

## Important Notes

- Jekyll version >= 3.8.6
- Theme: Minima ~> 2.0
- Changes to `_config.yml` require server restart
