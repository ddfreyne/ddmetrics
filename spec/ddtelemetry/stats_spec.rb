# frozen_string_literal: true

describe DDTelemetry::Stats do
  subject(:stats) { described_class.new(values) }

  context 'no values' do
    let(:values) { [] }

    it 'errors on #min' do
      expect { subject.min }
        .to raise_error(DDTelemetry::Stats::EmptyError)
    end

    it 'errors on #max' do
      expect { subject.max }
        .to raise_error(DDTelemetry::Stats::EmptyError)
    end

    it 'errors on #avg' do
      expect { subject.avg }
        .to raise_error(DDTelemetry::Stats::EmptyError)
    end

    it 'errors on #sum' do
      expect { subject.sum }
        .to raise_error(DDTelemetry::Stats::EmptyError)
    end

    its(:count) { is_expected.to eq(0) }
  end

  context 'one value' do
    let(:values) { [2.1] }

    its(:count) { is_expected.to eq(1) }
    its(:sum) { is_expected.to eq(2.1) }
    its(:avg) { is_expected.to eq(2.1) }
    its(:min) { is_expected.to eq(2.1) }
    its(:max) { is_expected.to eq(2.1) }

    it 'has proper quantiles' do
      expect(subject.quantile(0.00)).to eq(2.1)
      expect(subject.quantile(0.25)).to eq(2.1)
      expect(subject.quantile(0.50)).to eq(2.1)
      expect(subject.quantile(0.90)).to eq(2.1)
      expect(subject.quantile(0.99)).to eq(2.1)
    end
  end

  context 'two values' do
    let(:values) { [2.1, 4.1] }

    its(:count) { is_expected.to be_within(0.000001).of(2) }
    its(:sum) { is_expected.to be_within(0.000001).of(6.2) }
    its(:avg) { is_expected.to be_within(0.000001).of(3.1) }
    its(:min) { is_expected.to be_within(0.000001).of(2.1) }
    its(:max) { is_expected.to be_within(0.000001).of(4.1) }

    it 'has proper quantiles' do
      expect(subject.quantile(0.00)).to be_within(0.000001).of(2.1)
      expect(subject.quantile(0.25)).to be_within(0.000001).of(2.6)
      expect(subject.quantile(0.50)).to be_within(0.000001).of(3.1)
      expect(subject.quantile(0.90)).to be_within(0.000001).of(3.9)
      expect(subject.quantile(0.99)).to be_within(0.000001).of(4.08)
    end
  end
end
