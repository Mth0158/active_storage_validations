# frozen_string_literal: true

require 'test_helper'

module SizeValidatorMatcherTest
  module OnlyMatchWhenExactValue
    extend ActiveSupport::Concern

    included do
      describe 'standard validator' do
        describe 'when provided with a lower size than the size specified in the model validations' do
          subject { matcher.public_send(matcher_method, 0.5.kilobyte) }
  
          it { is_expected_not_to_match_for(klass) }
        end
  
        describe 'when provided with the exact size specified in the model validations' do
          subject { matcher.public_send(matcher_method, validator_value) }
  
          it { is_expected_to_match_for(klass) }
        end
  
        describe 'when provided with a higher size than the size specified in the model validations' do
          subject { matcher.public_send(matcher_method, 99.kilobytes) }
  
          it { is_expected_not_to_match_for(klass) }
        end
      end

      describe 'proc validator' do
        let(:matcher) { ActiveStorageValidations::Matchers::SizeValidatorMatcher.new(:"proc_#{model_attribute}") }

        describe 'when provided with a lower size than the size specified in the model validations' do
          subject { matcher.public_send(matcher_method, 0.5.kilobyte) }

          it { is_expected_not_to_match_for(klass) }
        end

        describe 'when provided with the exact size specified in the model validations' do
          subject { matcher.public_send(matcher_method, validator_value) }

          it { is_expected_to_match_for(klass) }
        end

        describe 'when provided with a higher size than the size specified in the model validations' do
          subject { matcher.public_send(matcher_method, 99.kilobytes) }

          it { is_expected_not_to_match_for(klass) }
        end
      end
    end
  end
end

describe ActiveStorageValidations::Matchers::SizeValidatorMatcher do
  include MatcherHelpers

  let(:matcher) { ActiveStorageValidations::Matchers::SizeValidatorMatcher.new(model_attribute) }
  let(:klass) { Size::Matcher }

  describe '#less_than' do
    let(:matcher_method) { :less_than }
    let(:model_attribute) { matcher_method }
    let(:validator_value) { 2.kilobytes }

    include SizeValidatorMatcherTest::OnlyMatchWhenExactValue
  end

  describe '#less_than_or_equal_to' do
    let(:matcher_method) { :less_than_or_equal_to }
    let(:model_attribute) { matcher_method }
    let(:validator_value) { 2.kilobytes }

    include SizeValidatorMatcherTest::OnlyMatchWhenExactValue
  end

  describe '#greater_than' do
    let(:matcher_method) { :greater_than }
    let(:model_attribute) { matcher_method }
    let(:validator_value) { 7.kilobytes }

    include SizeValidatorMatcherTest::OnlyMatchWhenExactValue
  end

  describe '#greater_than_or_equal_to' do
    let(:matcher_method) { :greater_than_or_equal_to }
    let(:model_attribute) { matcher_method }
    let(:validator_value) { 7.kilobytes }

    include SizeValidatorMatcherTest::OnlyMatchWhenExactValue
  end

  describe '#between' do
    let(:model_attribute) { :between }

    describe 'when provided with the exact sizes specified in the model validations' do
      subject { matcher.between 2.kilobytes..7.kilobytes }

      it { is_expected_to_match_for(klass) }
    end

    describe 'when provided with a higher size than the size specified in the model validations' do
      describe 'for the highest possible size' do
        subject { matcher.between 2.kilobytes..10.kilobytes }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'for the lowest possible size' do
        subject { matcher.between 5.kilobytes..7.kilobytes }

        it { is_expected_not_to_match_for(klass) }
      end
    end

    describe 'when provided with a lower size than the size specified in the model validations' do
      describe 'for the highest possible size' do
        subject { matcher.between 1.kilobytes..7.kilobytes }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'for the lowest possible size' do
        subject { matcher.between 1.kilobytes..7.kilobytes }

        it { is_expected_not_to_match_for(klass) }
      end
    end

    describe 'when provided with both lowest and highest possible sizes different than the model validations' do
      subject { matcher.between 4.kilobytes..20.kilobytes }

      it { is_expected_not_to_match_for(klass) }
    end
  end

  describe '#with_message' do
    let(:model_attribute) { :with_message }

    describe 'when provided with the exact size' do
      before { matcher.less_than_or_equal_to(5.megabytes) }

      describe 'and with the message specified in the model validations' do
        subject { matcher.with_message('File is too big.') }

        it { is_expected_to_match_for(klass) }
      end

      describe 'when provided with a different message than the one specified in the model validations' do
        subject { matcher.with_message('<wrong message>') }

        it { is_expected_not_to_match_for(klass) }
      end

      describe 'but without the #with_message matcher method' do
        subject { matcher }

        it { is_expected_to_match_for(klass) }
      end
    end
  end

  describe 'Combinations' do
    describe '#less_than + #with_message' do
      let(:model_attribute) { :less_than_with_message }

      describe 'when provided with the exact size' do
        describe 'and when provided with the message specified in the model validations' do
          subject do
            matcher.less_than 2.kilobytes
            matcher.with_message('File is too big.')
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end

    describe '#less_than_or_equal_to + #with_message' do
      let(:model_attribute) { :less_than_or_equal_to_with_message }

      describe 'when provided with the exact size' do
        describe 'and when provided with the message specified in the model validations' do
          subject do
            matcher.less_than_or_equal_to 2.kilobytes
            matcher.with_message('File is too big.')
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end

    describe '#greater_than + #with_message' do
      let(:model_attribute) { :greater_than_with_message }

      describe 'when provided with the exact size' do
        describe 'and when provided with the message specified in the model validations' do
          subject do
            matcher.greater_than 7.kilobytes
            matcher.with_message('File is too small.')
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end

    describe '#greater_than_or_equal_to + #with_message' do
      let(:model_attribute) { :greater_than_or_equal_to_with_message }

      describe 'when provided with the exact size' do
        describe 'and when provided with the message specified in the model validations' do
          subject do
            matcher.greater_than_or_equal_to 7.kilobytes
            matcher.with_message('File is too small.')
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end

    describe '#between + #with_message' do
      let(:model_attribute) { :between_with_message }

      describe 'when provided with the exact size' do
        describe 'and when provided with the message specified in the model validations' do
          subject do
            matcher.between 2.kilobyte..7.kilobytes
            matcher.with_message('File is not in accepted size range.')
          end

          it { is_expected_to_match_for(klass) }
        end
      end
    end
  end

  describe 'when the passed model attribute has a custom validation error message' do
    describe 'but the matcher is not provided with a #with_message' do
      subject { matcher.less_than_or_equal_to 5.megabytes }

      let(:model_attribute) { :with_message }

      it { is_expected_to_match_for(klass) }
    end
  end

  describe 'when the passed model attribute does not exist' do
    subject { matcher.less_than 2.kilobytes }

    let(:model_attribute) { :not_present_in_model }

    it { is_expected_not_to_match_for(klass) }
  end

  describe 'when the matcher is provided with an instance' do
    subject { matcher.less_than 2.kilobytes }

    let(:model_attribute) { :less_than }
    let(:instance) { klass.new }

    it { is_expected_to_match_for(instance) }
  end
end
