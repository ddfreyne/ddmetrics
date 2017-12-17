# frozen_string_literal: true

describe DDTelemetry::Counter do
  subject(:counter) { described_class.new }

  describe 'new counter' do
    it 'starts at 0' do
      expect(subject.get(:erb)).to eq(0)
      expect(subject.get(:haml)).to eq(0)
    end
  end

  describe '#increment' do
    subject { counter.increment(:erb) }

    it 'increments the matching value' do
      expect { subject }
        .to change { counter.get(:erb) }
        .from(0)
        .to(1)
    end

    it 'does not increment any other value' do
      expect(counter.get(:haml)).to eq(0)
      expect { subject }
        .not_to change { counter.get(:haml) }
    end
  end

  describe '#get' do
    subject { counter.get(:erb) }

    context 'not incremented' do
      it { is_expected.to eq(0) }
    end

    context 'incremented' do
      before { counter.increment(:erb) }
      it { is_expected.to eq(1) }
    end

    context 'other incremented' do
      before { counter.increment(:haml) }
      it { is_expected.to eq(0) }
    end
  end

  describe '#map' do
    subject { counter.map { |label, counter| [label, counter.value] } }

    context 'not incremented' do
      it { is_expected.to be_empty }
    end

    context 'incremented once' do
      before { counter.increment(:erb) }
      it { is_expected.to eq [[:erb, 1]] }
    end

    context 'both incremental multiple times' do
      before do
        counter.increment(:erb)
        counter.increment(:erb)
        counter.increment(:haml)
      end

      it { is_expected.to eq [[:erb, 2], [:haml, 1]] }
    end
  end

  describe '#to_s' do
    subject { counter.to_s }

    before do
      counter.increment(:erb)
      counter.increment(:erb)
      counter.increment(:haml)
    end

    it 'returns table' do
      expected = <<~TABLE
             │ count
        ─────┼──────
         erb │     2
        haml │     1
      TABLE

      expect(subject.strip).to eq(expected.strip)
    end
  end
end
