class TopicsController < PublicFacingController
  def index
    @topics = Topic.with_policies.alphabetical.all
  end

  def show
    @topic = Topic.find(params[:id])
    @policies = @topic.published_policies
    @publications = PublicationesquePresenter.decorate(Publication.in_topic([@topic]).by_published_at.limit(3))
    @announcements = AnnouncementPresenter.decorate(Announcement.in_topic([@topic]).in_reverse_chronological_order.limit(3))
    @detailed_guides = @topic.detailed_guides.published.limit(5)
    @related_topics = @topic.related_topics
    @recently_changed_documents = @topic.recently_changed_documents

    respond_to do |format|
      format.html {
        @recently_changed_documents = @recently_changed_documents[0...3]
      }
      format.atom {
        @recently_changed_documents = @recently_changed_documents[0...10]
      }
    end
  end
end
