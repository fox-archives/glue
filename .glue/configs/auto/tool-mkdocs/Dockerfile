FROM archlinux

RUN pacman -Sy --noconfirm python poetry git

RUN poetry init --name 'packageName' --description 'Description' --author 'author' -l MIT && \
	&& poetry add mkdocs mkdocs-material mkdocs-git-revision-date-localized-plugin mike mkdocs-mermaid2-plugin mkdocs-macros-plugin
