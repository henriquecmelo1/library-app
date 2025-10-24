require 'rails_helper'

RSpec.describe Material, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:author) { Person.create!(name: 'Author Name', date_of_birth: '1980-01-01') }

  subject {
    described_class.new(
      title: 'Sample Material',
      description: 'A description of the material.',
      status: 'draft',
      user: user,
      author: author
    )
  }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:user) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:author) }
  end

  describe '#as_json' do
    it 'returns a JSON representation of the material with compacted values' do
      json = subject.as_json
      expect(json).to include('title' => 'Sample Material')
      expect(json['author']).to include('id' => author.id, 'name' => 'Author Name')
    end
  end

  describe '#compact' do
    it 'removes nil values from the hash' do
      hash = { a: 1, b: nil, c: { d: nil, e: 2 } }
      compacted = subject.send(:compact, hash)
      expect(compacted).to eq({ a: 1, c: { e: 2 } })
    end
  end
end