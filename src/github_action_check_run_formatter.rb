# frozen_string_literal: true

require "pronto"
require_relative "annotation"

require "ostruct"

module Pronto
  module Formatter
    # The GithubActionCheckRunFormatter class is responsible for formatting and creating
    # GitHub Action Check Runs. It extends the Pronto::Formatter::Base class
    # and integrates with GitHub Actions to generate check runs based
    # on the messages produced by Pronto runners.
    #
    # This class handles the interaction with the GitHub API to create check runs for each
    # runner, providing detailed annotations and summaries of the analysis results.
    #
    # @attr_accessor [Array<Pronto::Message>] messages
    #   The collection of messages that need to be formatted into check runs.
    #
    # @attr_accessor [Pronto::Git::Repository] repo
    #   The repository object representing the Git repository being analyzed.
    #
    # @attr_accessor [String] sha
    #   The commit SHA for which the check runs are being created. This is typically
    #   the SHA of the head commit in the repository.
    #
    # @attr_accessor [Object] check_run
    #   The check run object that represents the current check run being processed.
    #   This object is used to store and manage the state of the check run.
    class GithubActionCheckRunFormatter < Base
      attr_accessor :messages, :repo, :sha, :check_run

      # @return [String] The name of the formatter.
      def self.name
        "github_action_check_run"
      end

      # Formats the messages into GitHub Action Check Runs.
      #
      # @param messages [Array<Pronto::Message>] The collection of messages to be formatted.
      # @param repo [Pronto::Git::Repository] The repository being analyzed.
      # @return [String] A summary of the number of check runs created.
      def format(messages, repo, _)
        self.messages = messages
        self.repo = repo
        self.sha = repo.head_commit_sha

        Runner.runners.each do |runner|
          create_check_run(runner, messages_by_runner[runner] || [])
        end

        "#{Runner.runners.size} Check Runs created"
      end

      # @return [Octokit::Client] The Octokit client configured with GitHub API credentials.
      def client
        @client ||= Octokit::Client.new(
          api_endpoint: config.github_api_endpoint,
          web_endpoint: config.github_web_endpoint,
          access_token: ENV.fetch("GITHUB_TOKEN") { config.github_access_token }
        )
      end

      # Creates a GitHub Action Check Run for a given runner and its messages.
      #
      # @param runner [Object] The runner for which the check run is being created.
      # @param runner_messages [Array<Pronto::Message>] The messages associated with the runner.
      # @return [void]
      def create_check_run(runner, runner_messages)
        line_annotations, no_line_annotations = runner_messages.map do |message|
          Annotation.new(message)
        end.partition(&:line?)
        output = OpenStruct.new(
          title: runner.title,
          summary: check_run_summary(runner, runner_messages),
          annotations: line_annotations.map(&:to_h).first(50)
        )
        if no_line_annotations.any?
          output.text = <<~TXT
            | sha | level | message |
            | --- | --- | --- |
            #{no_line_annotations.map(&:to_markdown_s).join("\n")}
          TXT
        end
        client.create_check_run(
          repo_slug,
          runner.title,
          sha,
          output: output.to_h,
          conclusion: runner_messages.any? ? :failure : :success,
          started_at: Time.now.iso8601,
          status: :completed,
          completed_at: Time.now.iso8601,
          accept: "application/vnd.github.antiope-preview+json"
        )
      end

      # Generates a summary for a GitHub Action Check Run.
      #
      # @param runner [Object] The runner for which the summary is being generated.
      # @param runner_messages [Array<Pronto::Message>] The messages associated with the runner.
      # @return [String] A summary of the check run, indicating the number of issues or a success message.
      def check_run_summary(runner, runner_messages)
        if runner_messages.any?
          <<~TXT
            There are #{runner_messages.size} issues raised by the #{runner.title} runner.
            See the information below for details.
          TXT
        else
          "Great job! You're all set here."
        end
      end

      # Retrieves the repository slug from the GitHub event or configuration.
      #
      # @return [String] The full name of the repository in the format "owner/repo".
      # @raise [RuntimeError] If the GitHub event path is not set and the slug is not found in the config.
      def repo_slug
        @repo_slug ||= if ENV.key?("GITHUB_EVENT_PATH")
          event = JSON.parse(File.read(ENV.fetch("GITHUB_EVENT_PATH")))
          event.fetch("repository").fetch("full_name")
        else
          config.github_slug || raise("no github.slug in pronto config")
        end
      end

      def messages_by_runner
        @messages_by_runner ||= messages.uniq.group_by(&:runner)
      end
    end
  end
end

Pronto::Formatter.register(Pronto::Formatter::GithubActionCheckRunFormatter)
