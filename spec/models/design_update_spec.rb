require 'rails_helper'

RSpec.describe DesignUpdate, type: :model do
  let(:valid_pdf) do
    Rack::Test::UploadedFile.new(
      StringIO.new('%PDF-1.4 test content'),
      'application/pdf',
      original_filename: 'test.pdf'
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      design_update = DesignUpdate.new(
        title: 'Test Update',
        update_date: Date.today,
        pdf_file: valid_pdf
      )
      expect(design_update).to be_valid
    end

    it 'is invalid without a title' do
      design_update = DesignUpdate.new(
        title: nil,
        update_date: Date.today,
        pdf_file: valid_pdf
      )
      expect(design_update).not_to be_valid
      expect(design_update.errors[:title]).to include("can't be blank")
    end

    it 'is invalid with a title longer than 200 characters' do
      design_update = DesignUpdate.new(
        title: 'a' * 201,
        update_date: Date.today,
        pdf_file: valid_pdf
      )
      expect(design_update).not_to be_valid
      expect(design_update.errors[:title]).to include('is too long (maximum is 200 characters)')
    end

    it 'is invalid without an update_date' do
      design_update = DesignUpdate.new(
        title: 'Test Update',
        update_date: nil,
        pdf_file: valid_pdf
      )
      expect(design_update).not_to be_valid
      expect(design_update.errors[:update_date]).to include("can't be blank")
    end

    it 'is invalid without a pdf_file on create' do
      design_update = DesignUpdate.new(
        title: 'Test Update',
        update_date: Date.today
      )
      expect(design_update).not_to be_valid
      expect(design_update.errors[:pdf_file]).to include("can't be blank")
    end

    it 'is invalid with a non-PDF file' do
      invalid_file = Rack::Test::UploadedFile.new(
        StringIO.new('not a pdf'),
        'text/plain',
        original_filename: 'test.txt'
      )
      design_update = DesignUpdate.new(
        title: 'Test Update',
        update_date: Date.today,
        pdf_file: invalid_file
      )
      expect(design_update).not_to be_valid
      expect(design_update.errors[:pdf_file]).to include('must be a PDF file')
    end

    it 'is invalid with a PDF file larger than 10MB' do
      large_pdf = Rack::Test::UploadedFile.new(
        StringIO.new("%PDF-1.4 #{'x' * (10.megabytes + 1)}"),
        'application/pdf',
        original_filename: 'large.pdf'
      )
      design_update = DesignUpdate.new(
        title: 'Test Update',
        update_date: Date.today,
        pdf_file: large_pdf
      )
      expect(design_update).not_to be_valid
      expect(design_update.errors[:pdf_file]).to include('must be less than 10MB')
    end
  end

  describe 'associations' do
    it 'has one attached pdf_file' do
      design_update = DesignUpdate.new(
        title: 'Test Update',
        update_date: Date.today
      )
      expect(design_update).to respond_to(:pdf_file)
    end
  end

  describe 'scopes' do
    describe '.recent' do
      it 'orders design updates by update_date descending' do
        # Create a temporary file for testing
        tempfile1 = Tempfile.new(['test1', '.pdf'])
        tempfile1.write('%PDF-1.4 test content')
        tempfile1.rewind

        tempfile2 = Tempfile.new(['test2', '.pdf'])
        tempfile2.write('%PDF-1.4 test content')
        tempfile2.rewind

        older_update = DesignUpdate.create!(
          title: 'Older Update',
          update_date: 1.week.ago,
          pdf_file: {
            io: tempfile1,
            filename: 'test1.pdf',
            content_type: 'application/pdf'
          }
        )

        newer_update = DesignUpdate.create!(
          title: 'Newer Update',
          update_date: Date.today,
          pdf_file: {
            io: tempfile2,
            filename: 'test2.pdf',
            content_type: 'application/pdf'
          }
        )

        results = DesignUpdate.recent
        expect(results.first).to eq(newer_update)
        expect(results.last).to eq(older_update)

        tempfile1.close
        tempfile1.unlink
        tempfile2.close
        tempfile2.unlink
      end
    end
  end
end
