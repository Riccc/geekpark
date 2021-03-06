# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :string
#  commenter        :string
#  state            :integer          default("normal")
#  upvote           :integer          default(0)
#  depth            :integer          default(0)
#  commentable_type :string
#  commentable_id   :integer
#  author           :string
#  parent_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#
# Indexes
#
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id)
#  index_comments_on_commenter                            (commenter)
#  index_comments_on_deleted_at                           (deleted_at)
#  index_comments_on_parent_id                            (parent_id)
#  index_comments_on_state                                (state)
#

class Comment < ApplicationRecord
  include SmartFilterable
  acts_as_paranoid

  belongs_to :commentable, polymorphic: true

  belongs_to :parent,
             class_name: 'Comment',
             optional: true,
             inverse_of: :children
  has_many :children,
           class_name: 'Comment',
           foreign_key: 'parent_id',
           inverse_of: :parent

  enum state: [:normal, :spam]

  validates_presence_of :commentable
  validates_presence_of :content
  validates_presence_of :state
  # validates_presence_of :user_id
  validate :parent_must_be_consistent_on_commentable

  def commentable_title
    commentable.try(:title)
  end

  private

  def parent_must_be_consistent_on_commentable
    return if parent_id.blank?
    if parent.commentable_id   != commentable_id ||
       parent.commentable_type != commentable_type
      errors.add(:parent_id, 'can\'t reply to comment on other threads')
    end
  end
end
