require 'rails_helper'

describe Activity, type: :model do
  context 'invalid params' do
    it 'must raise validation errors' do
      activity = Activity.new
      activity.valid?
      expect(activity.errors[:project].size).to eq(1)
      expect(activity.errors[:user].size).to eq(1)
      expect(activity.errors[:subject].size).to eq(1)
      expect(activity.errors[:action].size).to eq(2)
    end
  end

  context 'valid params' do
    let(:story) { create(:story, :with_project) }
    let(:activity) { build(:activity, action: 'update', subject: story ) }

    it "should save without parsing changes" do
      activity.action = 'create'
      expect(activity.save).to be_truthy
    end

    it "should fetch the changes from the model" do
      first_update = story.updated_at
      story.title = 'new story title'
      story.estimate = 2
      story.position = 1.5
      story.state = 'finished'
      
      story.save
      activity.save

      expect(activity.subject_changes).to eq({
        "title"=>["Test story", "new story title"],
        "estimate"=>[nil, 2],
        "position"=>[1.0, 1.5],
        "state"=>["unstarted", "finished"],
        "updated_at" => [first_update, story.updated_at]
      })
    end
  end

  context 'update with no changes' do
    let!(:story) { build(:story, :with_project) }
    let(:activity) { build(:activity, action: 'update', subject: story ) }

    it 'is invalid' do
      activity.valid?
      expect(activity.errors[:subject].count).to be(1)
    end
  end

  context '#grouped_activities' do
    let(:user) { create :user }
    let(:project) { create :project, users: [user] }
    let!(:story1) { create :story, project: project, requested_by: user }
    let!(:story2) { create :story, project: project, requested_by: user }
    let(:yesterday) { Time.current.yesterday }
    let(:today) { Time.current }

    before do
      Timecop.freeze(Time.utc(2016,10,5,12,0,0))
      Activity.destroy_all
      create :activity, subject: story1, subject_changes: { estimate: [0, 1] }
      create :activity, subject: story1, subject_changes: { estimate: [1, 2] }
      create :activity, subject: story1, subject_changes: { description: ['Foo', 'Hello'] }
      ref = create :activity, subject: story1, subject_changes: { description: ['Foo', 'Hello'] }
      Activity.update_all(created_at: yesterday, updated_at: yesterday)
      create :activity, subject: story2, subject_changes: { description: ['Hello WORLD', 'Hello World'] }
      create :activity, subject: story2, subject_changes: { description: ['Hello World', 'Hello'] }
      Activity.where("id > ?", ref.id).update_all(created_at: today, updated_at: today)
    end

    after do
      Timecop.return
    end

    it "should return a proper grouped list of merged activities" do
      grouped = Activity.grouped_activities(Project.all, Time.current - 2.days)
      expect(grouped.first.first).to eq(yesterday.beginning_of_day)
      expect(grouped.last.first).to eq(today.beginning_of_day)

      expect(grouped.first.last.last.last.last.last.first.subject_changes).to eq({:estimate=>[0, 2], :description=>["Foo", "Hello"]})
      expect(grouped.last.last.last.last.last.last.first.subject_changes).to eq({:description=>["Hello WORLD", "Hello"]})
    end
  end
end

