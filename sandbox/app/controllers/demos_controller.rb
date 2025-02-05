# frozen_string_literal: true

class DemosController < ApplicationController
  around_action :switch_locale

  def switch_locale(&action)
    locale = (params[:locale] || I18n.default_locale).to_s.downcase

    if I18n.available_locales.map(&:to_s).include?(locale)
      I18n.with_locale(locale, &action)
    else
      I18n.with_locale(I18n.default_locale, &action)
    end
  end

  def classic_controller_preset
    @preset = ckeditor5_preset do
      version '43.3.0'

      toolbar :sourceEditing, :|, :bold, :italic, :underline, :strikethrough,
              :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
              :fontFamily, :fontSize, :|, :link, :anchor, :|,
              :fontColor, :fontBackgroundColor, :|, :imageUpload

      plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
              :Subscript, :Superscript, :RemoveFormat, :List, :Link, :Font,
              :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing, :Essentials,
              :Paragraph, :Base64UploadAdapter

      plugins :Image, :ImageUpload, :ImageToolbar, :ImageInsert,
              :ImageInsertViaUrl, :ImageBlock, :ImageCaption, :ImageInline, :ImageResize,
              :AutoImage, :LinkImage
    end
  end

  def classic_wproofreader
    @preset = ckeditor5_preset(:default).override do
      wproofreader serviceId: '<enter your service key>',
                   srcUrl: 'https://svc.webspellchecker.net/spellcheck31/wscbundle/wscbundle.js'
    end
  end

  def locale_via_preset
    @preset = ckeditor5_preset(:default).override do
      language :ru
    end
  end

  def context
    @context_preset = ckeditor5_context_preset do
      inline_plugin :MagicContextPlugin, <<~JS
        const { Plugin } = await import( 'ckeditor5' );

        return class MagicContextPlugin extends Plugin {
          static get pluginName() {
            return 'MagicContextPlugin';
          }

          static get isContextPlugin() {
            return true;
          }

          async init() {
            console.log('MagicContextPlugin was initialized!');
            window.__magicPluginInitialized = this;
          }
        }
      JS
    end
  end

  def form_ajax
    return unless request.post?

    sleep(1)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'response',
          partial: 'form_ajax_response',
          locals: {
            content: params[:content],
            status: 'success'
          }
        )
      end
    end
  end

  def form_turbo_stream
    return unless request.post?

    sleep(1)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'response-stream',
          partial: 'form_turbo_stream_response',
          locals: {
            content: params[:content],
            status: 'success'
          }
        )
      end
    end
  end

  def special_characters
    @preset = ckeditor5_preset do # rubocop:disable Metrics/BlockLength
      version '43.3.0'

      toolbar :sourceEditing, :|, :bold, :italic, :underline,
              :strikethrough, :|, :specialCharacters, :|,
              :bulletedList, :numberedList, :|,
              :fontFamily, :fontSize, :|,
              :fontColor, :fontBackgroundColor

      plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline,
              :Strikethrough, :List, :Font, :FontFamily, :FontSize,
              :FontColor, :FontBackgroundColor, :SourceEditing

      special_characters do
        # Enable built-in packs using symbols
        packs :Text, :Essentials, :Currency, :Mathematical, :Latin

        # Custom groups
        group 'Emoji', label: 'Emoticons' do
          item 'smiley', '😊'
          item 'heart', '❤️'
        end

        group 'Arrows',
              items: [
                { title: 'right arrow', character: '→' },
                { title: 'left arrow', character: '←' }
              ]

        group 'Mixed',
              items: [{ title: 'star', character: '⭐' }],
              label: 'Mixed Characters' do
          item 'heart', '❤️'
        end

        order :Text, :Currency, :Mathematical, :Latin, :Emoji, :Arrows, :Mixed
      end
    end
  end
end
