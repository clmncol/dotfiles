vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
    gotmpl = "gotmpl",
    tmpl = "gotmpl",
    tpl = "gotmpl",
  },
  filename = {
    [".gitlab-ci.yml"] = "yaml.gitlab",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
    ["values.yaml"] = "yaml.helm-values",
    ["values.yml"] = "yaml.helm-values",
  },
  pattern = {
    [".*docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    [".*compose.*%.ya?ml"] = "yaml.docker-compose",
    [".*%.gitlab%.ya?ml"] = "yaml.gitlab",

    -- Helm templates / Go templates
    [".*/templates/.*%.ya?ml"] = "gotmpl",
    [".*/templates/.*%.tpl"] = "gotmpl",
    [".*/templates/.*%.txt"] = "gotmpl",

    -- Common Go template naming
    [".*%.tmpl"] = "gotmpl",
    [".*%.gotmpl"] = "gotmpl",

    -- Helm values variants
    [".*/values.*%.ya?ml"] = "yaml.helm-values",
  },
})
