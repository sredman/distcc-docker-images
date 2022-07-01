# Distcc server images

I use this image to build distributed from my laptop when I don't want to wait.

This article by Konrad Kleine about compiling with distcc containers is a great place to start:

On Red Hat Developer Blog: https://developers.redhat.com/blog/2019/05/15/2-tips-to-make-your-c-projects-compile-3-times-faster/

On Medium: https://link.medium.com/cfhBeb298V

## Quickstart

This section is mostly written for myself but I hope you will find it useful.

### Build Docker Image

Since I only infrequently use this, it is simpler to just build it on the machine where I want to run it.

Download the sourcecode from this repository. Unzip the folder.

```
cd ~/Downloads/distcc-docker-images-*
docker build -t fedora## .
```

Replace `##` with the fedora version of the base image

### Run Docker image

```
docker run -p 3632:3632 -p 3633:3633 fedora## --allow 0.0.0.0/0
```

Replace `##` with whatever you used when creating the image

### Set up build host

```
export DISTCC_HOSTS='localhost/jobs hostname:3632/jobs'
```

Replace `jobs` with a number, indicating the max number of jobs to run on that host.

This can also be saved to /etc/distcc/hosts

### Build

```
make -j32 CC="distcc gcc" [target]
```

Replace `[target]` with the desired target

Pro tip: Put `time` first to see how much faster you're building now!
