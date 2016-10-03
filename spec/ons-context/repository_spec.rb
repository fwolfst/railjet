require "ons-context/repository/registry"
require "ons-context/repository"

describe OnsContext::Repository::Registry do
  let(:app_registry) { Class.new(described_class).new }

  describe "#register" do
    let(:query)  { double('UserRecord') }
    let(:cupido) { double('Cupido::User') }

    let(:repo) do
      Class.new do
        include OnsContext::Repository
        include OnsContext::Repository::ActiveRecordRepository
        include OnsContext::Repository::CupidoRepository

        def build_user(hash = {})
          query.new(hash)
        end

        def push_user(hash = {})
          cupido.push(hash)
        end
      end
    end

    before do
      app_registry.register(:user, repo, query: query, cupido: cupido)
    end

    it "creates accessor method" do
      expect(app_registry).to respond_to :users
    end

    describe "defined accessor" do
      let(:users) { app_registry.users }

      it "calls ActiveRecord properly" do
        expect(query).to receive(:new).with(name: "John Doe")
        users.build_user(name: "John Doe")
      end

      it "calls Cupido properly" do
        expect(cupido).to receive(:push).with(name: "John Doe")
        users.push_user(name: "John Doe")
      end
    end
  end
end