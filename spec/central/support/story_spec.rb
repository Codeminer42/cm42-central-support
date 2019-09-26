require 'rails_helper'

describe Story, type: :model do
  subject { build :story, :with_project }
  before do
    subject.acting_user = build(:user)
  end

  describe 'validations' do
    describe '#title' do
      it 'is required' do
        subject.title = ''
        subject.valid?
        expect(subject.errors[:title].size).to eq(1)
      end
    end

    describe '#story_type' do
      it { is_expected.to validate_presence_of(:story_type) }
      it { is_expected.to enumerize(:story_type).in('feature', 'chore', 'bug', 'release') }
    end

    describe '#state' do
      it 'must be a valid state' do
        subject.state = 'flum'
        subject.valid?
        expect(subject.errors[:state].size).to eq(1)
      end
    end

    describe '#project' do
      it 'cannot be nil' do
        subject.project_id = nil
        subject.valid?
        expect(subject.errors[:project].size).to eq(1)
      end

      it 'must have a valid project_id' do
        subject.project_id = 'invalid'
        subject.valid?
        expect(subject.errors[:project].size).to eq(1)
      end

      it 'must have a project' do
        subject.project = nil
        subject.valid?
        expect(subject.errors[:project].size).to eq(1)
      end
    end

    describe '#estimate' do
      before do
        subject.project.users = [subject.requested_by]
      end

      it 'must be valid for the project point scale' do
        subject.project.point_scale = 'fibonacci'
        subject.estimate = 4 # not in the fibonacci series
        subject.valid?
        expect(subject.errors[:estimate].size).to eq(1)
      end

      context 'when try to estimate' do
        %w[chore bug release].each do |type|
          context "a #{type} story" do
            before { subject.attributes = { story_type: type, estimate: 1 } }

            it { is_expected.to be_invalid }
          end
        end

        context 'a feature story' do
          before { subject.attributes = { story_type: 'feature', estimate: 1 } }

          it { is_expected.to be_valid }
        end
      end
    end
  end

  describe 'associations' do
    describe 'notes' do
      let!(:user) { create :user }
      let!(:project) { create :project, users: [user] }
      let!(:story) { create :story, project: project, requested_by: user }
      let!(:note) { create(:note, created_at: Date.current + 2.days, user: user, story: story) }
      let!(:note2) { create(:note, created_at: Date.current, user: user, story: story) }

      it 'order by created at' do
        story.reload

        expect(story.notes).to eq [note2, note]
      end
    end
  end

  describe '#to_s' do
    before { subject.title = 'Dummy Title' }
    its(:to_s) { should == 'Dummy Title' }
  end

  describe '#estimated?' do
    context 'when the story estimation is nil' do
      before { subject.estimate = nil }

      it { is_expected.not_to be_estimated }
    end

    context 'when the story estimation is 1' do
      before { subject.estimate = 1 }

      it { is_expected.to be_estimated }
    end
  end

  describe '#estimable_type?' do
    %w[chore bug release].each do |type|
      context "when is a #{type} story" do
        before { subject.story_type = type }

        it { is_expected.not_to be_estimable_type }
      end
    end

    context 'when is a feature story' do
      before { subject.story_type = 'feature' }

      it { is_expected.to be_estimable_type }
    end
  end

  describe '#set_position_to_last' do
    context 'when position is set' do
      before { subject.position = 42 }

      it 'does nothing' do
        expect(subject.set_position_to_last).to be true
        subject.position = 42
      end
    end

    context 'when there are no other stories' do
      before { allow(subject).to receive_message_chain(:project, :stories, :order, :first).and_return(nil) }

      it 'sets position to 1' do
        subject.set_position_to_last
        expect(subject.position).to eq(1)
      end
    end

    context 'when there are other stories' do
      let(:last_story) { mock_model(Story, position: 41) }

      before do
        allow(subject).to receive_message_chain(:project, :stories, :order, :first).and_return(last_story)
      end

      it 'incrememnts the position by 1' do
        subject.set_position_to_last
        expect(subject.position).to eq(42)
      end
    end
  end

  describe '#accepted_at' do
    context 'when not set' do
      before { subject.accepted_at = nil }

      # FIXME: This is non-deterministic
      it "gets set when state changes to 'accepted'" do
        Timecop.freeze(Time.zone.parse('2016-08-31 12:00:00')) do
          subject.started_at = 5.days.ago
          subject.update_attribute :state, 'accepted'
          expect(subject.accepted_at).to eq(Time.current)
          expect(subject.cycle_time_in(:days)).to eq(5)
        end
      end
    end

    context 'when set' do
      before { subject.accepted_at = Time.zone.parse('1999/01/01') }

      # FIXME: This is non-deterministic
      it "is unchanged when state changes to 'accepted'" do
        subject.update_attribute :state, 'accepted'
        expect(subject.accepted_at).to eq(Time.zone.parse('1999/01/01'))
      end
    end
  end

  describe '#delivered_at' do
    context 'when not set' do
      before { subject.delivered_at = nil }

      it 'gets set when state changes to delivered_at' do
        Timecop.freeze(Time.zone.parse('2016-08-31 12:00:00')) do
          subject.update_attribute :state, 'delivered'
          expect(subject.delivered_at).to eq(Time.current)
        end
      end
    end

    context 'when there is already a delivered_at' do
      before { subject.delivered_at = Time.zone.parse('1999/01/01') }

      it 'is unchanged' do
        subject.update_attribute :state, 'delivered'
        expect(subject.delivered_at).to eq(Time.zone.parse('1999/01/01'))
      end
    end

    context 'when state does not change' do
      before { subject.delivered_at = nil }

      it 'delivered_at is not filled' do
        subject.update_attribute :title, 'New title'
        expect(subject.delivered_at).to eq(nil)
      end
    end
  end

  describe '#started_at' do
    context 'when not set' do
      before do
        subject.started_at = subject.owned_by = nil
      end

      # FIXME: This is non-deterministic
      it "gets set when state changes to 'started'" do
        Timecop.freeze(Time.zone.parse('2016-08-31 12:00:00')) do
          subject.update_attribute :state, 'started'
          expect(subject.started_at).to eq(Time.current)
          expect(subject.owned_by).to eq(subject.acting_user)
        end
      end
    end

    context 'when set' do
      before { subject.started_at = Time.zone.parse('2016-09-01 13:00:00') }

      # FIXME: This is non-deterministic
      it "is unchanged when state changes to 'started'" do
        subject.update_attribute :state, 'started'
        expect(subject.started_at).to eq(Time.zone.parse('2016-09-01 13:00:00'))
        expect(subject.owned_by).to eq(subject.acting_user)
      end
    end
  end

  describe '#to_csv' do
    let(:story) { create(:story, :with_project) }

    let(:number_of_extra_columns) { { tasks: 0, notes: 0, documents: 0 } }
    let(:task) { double('task') }
    let(:tasks) { [task] }

    let(:note) { double('note') }
    let(:notes) { [note] }

    let(:document) { double('document') }
    let(:documents) { [document] }

    before do
      allow(story).to receive(:tasks).and_return(tasks)
      allow(story).to receive(:notes).and_return(notes)
      allow(story).to receive(:documents).and_return(documents)
    end

    it 'returns an array' do
      expect(story.to_csv(number_of_extra_columns)).to be_kind_of(Array)
    end

    it 'has the same number of elements as the .csv_headers' do
      expect(story.to_csv(number_of_extra_columns).length).to eq(Story.csv_headers.length)
    end

    context 'when story have tasks' do
      let(:task_name) { 'task_name' }
      let(:task_status) { 'completed' }

      before do
        allow(task).to receive(:to_csv).and_return([task_name, task_status])
        number_of_extra_columns[:tasks] = 1
      end

      it 'return task name' do
        expect(story.to_csv(number_of_extra_columns)).to include(task_name)
      end

      it 'return task status' do
        expect(story.to_csv(number_of_extra_columns)).to include(task_status)
      end
    end

    context 'when story have notes' do
      let(:note_body) { 'This is the note body text (Note Author - Dec 25, 2011)' }

      before do
        allow(note).to receive(:to_csv).and_return(note_body)
        number_of_extra_columns[:notes] = 1
      end

      it 'return note body' do
        expect(story.to_csv(number_of_extra_columns)).to include(note_body)
      end
    end

    context 'when story have documents' do
      let(:document_content) do
        '{"attachinariable_type"=>"Story",
          "scope"=>"documents",
          "public_id"=>"programming-motherfucker-1-728_qhl2tl",
          "version"=>"1540488712",
          "width"=>728,
          "height"=>546,
          "format"=>"jpg",
          "resource_type"=>"image"}'
      end

      before do
        allow(document).to receive(:to_csv).and_return(document_content)
        number_of_extra_columns[:documents] = 1
      end

      it 'return note body' do
        expect(story.to_csv(number_of_extra_columns)).to include(document_content)
      end
    end
  end

  describe '#stakeholders_users' do
    let(:requested_by)  { mock_model(User) }
    let(:owned_by)      { mock_model(User) }
    let(:note_user)     { mock_model(User) }
    let(:notes)         { [mock_model(Note, user: note_user)] }

    before do
      subject.requested_by  = requested_by
      subject.owned_by      = owned_by
      subject.notes         = notes
    end

    specify do
      expect(subject.stakeholders_users).to include(requested_by)
    end

    specify do
      expect(subject.stakeholders_users).to include(owned_by)
    end

    specify do
      expect(subject.stakeholders_users).to include(note_user)
    end

    it 'strips out nil values' do
      subject.requested_by = subject.owned_by = nil
      expect(subject.stakeholders_users).not_to include(nil)
    end
  end

  context 'when unscheduled' do
    before { subject.state = 'unscheduled' }
    its(:events)  { should == [:start] }
    its(:column)  { should == '#chilly_bin' }
  end

  context 'when unstarted' do
    before { subject.state = 'unstarted' }
    its(:events)  { should == [:start] }
    its(:column)  { should == '#backlog' }
  end

  context 'when started' do
    before { subject.state = 'started' }
    its(:events)  { should == [:finish] }
    its(:column)  { should == '#in_progress' }
  end

  context 'when finished' do
    before { subject.state = 'finished' }
    its(:events)  { should == [:deliver] }
    its(:column)  { should == '#in_progress' }
  end

  context 'when delivered' do
    before { subject.state = 'delivered' }
    its(:events)  { should include(:accept) }
    its(:events)  { should include(:reject) }
    its(:column)  { should == '#in_progress' }
  end

  context 'when rejected' do
    before { subject.state = 'rejected' }
    its(:events)  { should == [:restart] }
    its(:column)  { should == '#in_progress' }
  end

  context 'when accepted' do
    before { subject.state = 'accepted' }
    its(:events)  { should == [] }
    its(:column)  { should == '#done' }
  end

  describe '.csv_headers' do
    specify { expect(Story.csv_headers).to be_kind_of(Array) }
  end

  describe '#cache_user_names' do
    context 'when adding a requester and owner to a story' do
      let(:requester)  { build(:user) }
      let(:owner)      { build(:user) }
      let(:story) { create(:story, :with_project, owned_by: nil, requested_by: requester) }

      before do
        story.update_attributes(owned_by: owner)
      end

      specify { expect(story.requested_by_name).to eq(requester.name) }
      specify { expect(story.owned_by_name).to eq(owner.name) }
      specify { expect(story.owned_by_initials).to eq(owner.initials) }
    end

    context 'when removing a owner to a story' do
      let(:owner) { build(:user) }
      let(:story) { create(:story, :with_project, owned_by: owner) }

      before do
        story.update_attributes(owned_by: nil)
      end

      specify { expect(story.owned_by_name).to be_nil }
      specify { expect(story.owned_by_initials).to be_nil }
    end

    context 'when changing a requested and owner of a story' do
      let(:requester)     { build(:user) }
      let(:owner)         { build(:user) }
      let(:requester2)    { build(:user) }
      let(:owner2)        { build(:user) }
      let(:story) { create(:story, :with_project, owned_by: owner, requested_by: requester) }

      before do
        story.update_attributes(owned_by: owner2, requested_by: requester2)
      end

      specify { expect(story.requested_by_name).to eq(requester2.name) }
      specify { expect(story.owned_by_name).to eq(owner2.name) }
      specify { expect(story.owned_by_initials).to eq(owner2.initials) }
    end
  end
end
