module ApplicationHelper
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end

  def show_title?
    @show_title
  end
  
  def app_name
    @app_name ||= Rails.application.class.to_s.split("::").first
  end
end
