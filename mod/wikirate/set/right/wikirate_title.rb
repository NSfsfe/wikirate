view :needed, perms: :none do
  if card.real? && !card.content.empty?
    render_core
  else
    raw %(<span class="wanted-card">title needed</span>)
  end
end
