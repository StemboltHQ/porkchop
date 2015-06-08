require 'rails_helper'

RSpec.describe Matchmaker do
  describe "#choose" do
    let(:matchmaker) { Matchmaker.new(players) }
    let(:least_recently_played_player) { FactoryGirl.create :player, name: "Least", active: true }

    subject { matchmaker.choose }

    context "when there are no players" do
      let(:players) { [] }

      it { is_expected.to be_a Matchup }
      it { is_expected.not_to be_valid }
    end

    context "when there are 2 players" do
      let(:other_player) { FactoryGirl.create :player, active: true }
      let(:players) { [least_recently_played_player, other_player] }

      it { is_expected.to be_a Matchup }
      it { is_expected.to be_valid }
    end

    context "when there are 3 or more players" do
      let(:other_player) { FactoryGirl.create :player, name: "Other", active: true }
      let(:another_player) { FactoryGirl.create :player, name: "Another", active: true }
      let(:players) { [least_recently_played_player, other_player, another_player] }

      it { is_expected.to be_a Matchup }
      it { is_expected.to be_valid }
    end
  end

  describe "explain" do
    subject { matchmaker.explain }

    let(:matchmaker) { Matchmaker.new(players) }
    let(:players) { [bert, ernie] }
    let(:ernie) { FactoryGirl.create :player, name: "Ernie", active: true }
    let(:bert) { FactoryGirl.create :player, name: "Bert", active: true }

    it "returns an arbitrary representation of the result of the matchup ranking" do
      expect(subject).to eq [{
        players: ["Bert", "Ernie"],
        result: 22.0,
        breakdown: [
          {
            name: "Matchup matches since last played",
            base_value: 2.0,
            factor: 1.0,
            value: 2.0
          },
          {
            name: "Players who should have played by now",
            base_value: 2.0,
            factor: 10.0,
            value: 20.0
          }
        ]
      }]
    end
  end

  describe "matchmaking algorithm" do
    context "with 5 players playing 40 matches", :focus do
      let!(:players) { FactoryGirl.create_list(:player, 5, active: true) }
      before { 80.times { Match.setup!.finalize! } }

      it "plays all matchups" do
        Player.find_each do |player|
          expect(player.matches.count).to be_within(3).of 32
        end
      end
    end
  end
end
