.PHONY: test-ubuntu test-fedora test-all clean

# Allow overriding the container runtime (e.g., make test-ubuntu DOCKER=docker)
DOCKER ?= podman

test-ubuntu:
	@echo "=> Testing installation on Ubuntu (latest)"
	$(DOCKER) run --rm -v "$(PWD):/test-repo:z" ubuntu:latest /bin/bash -c "\
		apt-get update && apt-get install -y sudo curl git && \
		useradd -m -s /bin/bash testuser && \
		echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
		cp -r /test-repo /home/testuser/dotfiles && \
		chown -R testuser:testuser /home/testuser/dotfiles && \
		su - testuser -c 'cd /home/testuser/dotfiles && bash ./install.sh'"

test-fedora:
	@echo "=> Testing installation on Fedora (latest)"
	$(DOCKER) run --rm -v "$(PWD):/test-repo:z" fedora:latest /bin/bash -c "\
		dnf update -y && dnf install -y sudo curl git && \
		useradd -m -s /bin/bash testuser && \
		echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
		cp -r /test-repo /home/testuser/dotfiles && \
		chown -R testuser:testuser /home/testuser/dotfiles && \
		su - testuser -c 'cd /home/testuser/dotfiles && bash ./install.sh'"

test-all: test-ubuntu test-fedora

clean:
	@echo "=> Cleaning up test container images to save disk space"
	$(DOCKER) rmi ubuntu:latest fedora:latest -f || true
	$(DOCKER) image prune -f
