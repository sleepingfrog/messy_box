# frozen_string_literal: true
require 'benchmark/ips'
require 'benchmark/memory'

namespace :view_component do
  task bench: :environment do
    class BenchMarkController < ActionController::Base; end
    view_context = BenchMarkController.new.view_context

    @user = User.first

    Benchmark.ips do |x|
      x.time = 10
      x.warmup = 2

      x.report('component') { view_context.render(UserNameComponent.new(user: @user)) }
      x.report('partial') { view_context.render(partial: 'shared/user/name', locals: { user: @user }) }
      x.report('cells') { view_context.cell(User::Cell::Name, @user) }

      x.compare!
    end

    Benchmark.memory do |x|
      x.report('component') { view_context.render(UserNameComponent.new(user: @user)) }
      x.report('partial') { view_context.render(partial: 'shared/user/name', locals: { user: @user }) }
      x.report('cells') { view_context.cell(User::Cell::Name, @user) }

      x.compare!
    end
  end

  task collection_bench: :environment do
    class BenchMarkController < ActionController::Base; end
    view_context = BenchMarkController.new.view_context

    @users = User.all

    Benchmark.ips do |x|
      x.time = 10
      x.warmup = 2

      x.report('component') { view_context.render(UserNameComponent.with_collection(@users)) }
      x.report('partial') { view_context.render(partial: 'shared/user/name', collection: @users, as: :user) }
      x.report('cells') { view_context.cell(User::Cell::Name, collection: @users) }

      x.compare!
    end

    Benchmark.memory do |x|
      x.report('component') { view_context.render(UserNameComponent.with_collection(@users)) }
      x.report('partial') { view_context.render(partial: 'shared/user/name', collection: @users, as: :user) }
      x.report('cells') { view_context.cell(User::Cell::Name, collection: @users) }

      x.compare!
    end
  end
end
