module UserItemVotesHelper
  def link_to_upvote(object)
    link_to 'like!', vote_item_path(object), method: :post, class: 'text-danger'
  end

  def link_to_downvote(object)
    link_to 'unlike!', vote_item_path(object), method: :delete, class: 'text-muted'
  end

  def votes_if_liked(item)
    link_to content_tag(:span, '', :class => 'glyphicon glyphicon-arrow-up'), vote_item_path(item.id), method: :post, class: 'text-success'
  end

  def votes_if_disliked(item)
    link_to content_tag(:span, '', :class => 'glyphicon glyphicon-arrow-down'), vote_item_path(item.id), method: :delete, class: 'text-danger'
  end

  def votes_if_neutral(item)
    'vote'
  end

  def render_votes_for_item(item=nil)
      if item.votes_for.up.by_type(User).voters.collect {|x| x.id}.include?(current_user.id)
        votes_if_liked(item)
      elsif item.votes_for.down.by_type(User).voters.collect {|x| x.id}.include?(current_user.id)
        votes_if_disliked(item)
      else
        votes_if_neutral(item)
      end
  end

  def render_link_to_user(user, options={})
    if user.disabled?
      user.username
    else
      link_to user.username, user, options
    end
  end
end
