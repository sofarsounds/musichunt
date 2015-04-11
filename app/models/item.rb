class Item < ActiveRecord::Base
  belongs_to :user
  has_many :votes, as: :votable
  has_many :comments, class_name: "ItemComment"
  acts_as_votable

  validates :title, presence: true, length: { maximum: 250 }, allow_blank: false, allow_nil: false
  validates :id, uniqueness: true

  validate do
    if content.blank? && url.blank?
      errors.add(:url, 'Submit a URL or Content')
    end
    if content.present? && url.present?
      errors.add(:url, 'Submit a URL or Content but not Both.')
    end
  end
  validates :url, url: {allow_nil: true, allow_blank: true}


  scope :active, -> { where(disabled: false) }
  scope :disabled, -> { where(disabled: true) }
  scope :newest, -> { order(score: :desc) }

  def host
    URI.parse(self.url).host
  rescue
    nil
  end

  def up_voted_by?(user)
    assign_up_voters

    if @up_voters.collect {|x| x.id}.include?(user.id)
      true
    else
      false
    end
  end

  def down_voted_by?(user)
    assign_down_voters

    if @down_voters.collect {|x| x.id}.include?(user.id)
      true
    else
      false
    end
  end

  protected
    def assign_up_voters
      @up_voters = self.votes_for.up.by_type(User).voters unless @up_voters
      @up_voters
    end
    def assign_down_voters
      @down_voters = self.votes_for.down.by_type(User).voters unless @down_voters
      @down_voters
    end

end
