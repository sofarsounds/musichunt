module ApplicationHelper

  def site_title_text
    ENV["SITE_TITLE"] || "RRHNClone."
  end

  def seo_title_text
    ENV["SEO_TITLE"] || "Rails Hackernews Reddit Producthunt Clone Github"
  end

  def link_to_list_item(name, link, options={})
    options = current_page?(link) ? {class: "active"} : {}
    content_tag :li, options do
      link_to name, link, options
    end
  end

  def pluralize_without_count(count, noun, text = nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end

end
