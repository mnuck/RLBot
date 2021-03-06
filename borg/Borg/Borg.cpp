// Borg.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>

#include <grpc/grpc.h>
#include <grpc++/server.h>
#include <grpc++/server_builder.h>
#include <grpc++/server_context.h>
#include <grpc++/security/server_credentials.h>
#include "../game_data.grpc.pb.h"

extern "C" {
#include "../nimcache/core.h"
}

class BotImpl final : public rlbot::api::Bot::Service {

	grpc::Status GetControllerState(grpc::ServerContext* context, 
		                            const rlbot::api::GameTickPacket* request,
		                            rlbot::api::ControllerState* response) {
		auto copyVector = [](auto& a, auto& b) {
			a.X = b.x();
			a.Y = b.y();
			a.Z = b.z();
		};
		auto copyRotation = [](auto& a, auto& b) {
			a.Yaw = b.yaw();
			a.Pitch = b.pitch();
			a.Roll = b.roll();
		};

		ClearGameTickPacket();
		SetPlayerIndex(request->player_index());
		{
			BallInfo ball;
			auto& req = request->ball();
			copyVector(ball.Location, req.location());
			copyVector(ball.Velocity, req.velocity());
			copyVector(ball.AngularVelocity, req.angular_velocity());
			copyVector(ball.Acceleration, req.acceleration());
			copyRotation(ball.Rotation, req.rotation());
			ball.LatestTouch.GameSeconds = req.latest_touch().game_seconds();
			ball.LatestTouch.PlayerName = (char*)malloc(strlen(req.latest_touch().player_name().c_str()) + 1);
			strcpy(ball.LatestTouch.PlayerName, req.latest_touch().player_name().c_str());
			copyVector(ball.LatestTouch.Location, req.latest_touch().location());
			copyVector(ball.LatestTouch.Normal, req.latest_touch().normal());
			SetBallInfo(&ball);
			free(ball.LatestTouch.PlayerName);
		}
		{
			GameInfo game;
			auto& req = request->game_info();
			game.SecondsElapsed = req.seconds_elapsed();
			game.GameTimeRemaining = req.game_time_remaining();
			game.IsOverTime = req.is_overtime();
			game.IsUnlimitedTime = req.is_unlimited_time();
			game.IsRoundActive = req.is_round_active();
			game.IsKickoffPause = req.is_kickoff_pause();
			game.IsMatchEnded = req.is_match_ended();
			SetGameInfo(&game);
		}
		for (int i = 0; i < request->players_size(); ++i) {
			PlayerInfo player;
			const auto& req = request->players().Get(i);
			copyVector(player.Location, req.location());
			copyVector(player.Velocity, req.velocity());
			copyVector(player.AngularVelocity, req.angular_velocity());
			copyRotation(player.Rotation, req.rotation());
			player.ScoreInfo.Score = req.score_info().score();
			player.ScoreInfo.Goals = req.score_info().goals();
			player.ScoreInfo.OwnGoals = req.score_info().own_goals();
			player.ScoreInfo.Assists = req.score_info().assists();
			player.ScoreInfo.Saves = req.score_info().saves();
			player.ScoreInfo.Shots = req.score_info().shots();
			player.ScoreInfo.Demolitions = req.score_info().demolitions();
			player.IsDemolished = req.is_demolished();
			player.IsMidair = req.is_midair();
			player.IsSuperSonic = req.is_supersonic();
			player.IsBot = req.is_bot();
			player.Jumped = req.jumped();
			player.DoubleJumped = req.double_jumped();
			player.Name = (char*)malloc(strlen(req.name().c_str()) + 1);
			strcpy(player.Name, req.name().c_str());
			AddPlayerInfo(&player);
			free(player.Name);
		}
		for (int i = 0; i < request->boost_pads_size(); ++i) {
			BoostInfo boost;
			const auto& req = request->boost_pads().Get(i);
			copyVector(boost.Location, req.location());
			boost.IsActive = req.is_active();
			boost.Timer = req.timer();
			AddBoostInfo(&boost);
		}

		::ControllerState state = ::GetControllerState();
		response->set_throttle(state.Throttle);
		response->set_steer(state.Steer);
		response->set_pitch(state.Pitch);
		response->set_yaw(state.Yaw);
		response->set_roll(state.Roll);
		response->set_jump(state.Jump);
		response->set_boost(state.Boost);
		response->set_handbrake(state.Handbrake);
		return grpc::Status::OK;
	}
};

int main()
{
	NimMain();
	std::string server_address("0.0.0.0:34865");
	BotImpl service;
	grpc::ServerBuilder builder;
	builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
	builder.RegisterService(&service);
	std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
	std::cout << "Server listening on " << server_address << std::endl;
	server->Wait();
    return 0;
}

