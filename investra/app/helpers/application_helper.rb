module ApplicationHelper
  def nav_class(current_path, target_path)
    "nav__link #{current_path == target_path ? 'is-active' : ''}"
  end
end
