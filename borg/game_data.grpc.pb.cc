// Generated by the gRPC C++ plugin.
// If you make any local change, they will be lost.
// source: game_data.proto

#include "game_data.pb.h"
#include "game_data.grpc.pb.h"

#include <grpc++/impl/codegen/async_stream.h>
#include <grpc++/impl/codegen/async_unary_call.h>
#include <grpc++/impl/codegen/channel_interface.h>
#include <grpc++/impl/codegen/client_unary_call.h>
#include <grpc++/impl/codegen/method_handler_impl.h>
#include <grpc++/impl/codegen/rpc_service_method.h>
#include <grpc++/impl/codegen/service_type.h>
#include <grpc++/impl/codegen/sync_stream.h>
namespace rlbot {
namespace api {

static const char* Bot_method_names[] = {
  "/rlbot.api.Bot/GetControllerState",
};

std::unique_ptr< Bot::Stub> Bot::NewStub(const std::shared_ptr< ::grpc::ChannelInterface>& channel, const ::grpc::StubOptions& options) {
  (void)options;
  std::unique_ptr< Bot::Stub> stub(new Bot::Stub(channel));
  return stub;
}

Bot::Stub::Stub(const std::shared_ptr< ::grpc::ChannelInterface>& channel)
  : channel_(channel), rpcmethod_GetControllerState_(Bot_method_names[0], ::grpc::internal::RpcMethod::NORMAL_RPC, channel)
  {}

::grpc::Status Bot::Stub::GetControllerState(::grpc::ClientContext* context, const ::rlbot::api::GameTickPacket& request, ::rlbot::api::ControllerState* response) {
  return ::grpc::internal::BlockingUnaryCall(channel_.get(), rpcmethod_GetControllerState_, context, request, response);
}

::grpc::ClientAsyncResponseReader< ::rlbot::api::ControllerState>* Bot::Stub::AsyncGetControllerStateRaw(::grpc::ClientContext* context, const ::rlbot::api::GameTickPacket& request, ::grpc::CompletionQueue* cq) {
  return ::grpc::internal::ClientAsyncResponseReaderFactory< ::rlbot::api::ControllerState>::Create(channel_.get(), cq, rpcmethod_GetControllerState_, context, request, true);
}

::grpc::ClientAsyncResponseReader< ::rlbot::api::ControllerState>* Bot::Stub::PrepareAsyncGetControllerStateRaw(::grpc::ClientContext* context, const ::rlbot::api::GameTickPacket& request, ::grpc::CompletionQueue* cq) {
  return ::grpc::internal::ClientAsyncResponseReaderFactory< ::rlbot::api::ControllerState>::Create(channel_.get(), cq, rpcmethod_GetControllerState_, context, request, false);
}

Bot::Service::Service() {
  AddMethod(new ::grpc::internal::RpcServiceMethod(
      Bot_method_names[0],
      ::grpc::internal::RpcMethod::NORMAL_RPC,
      new ::grpc::internal::RpcMethodHandler< Bot::Service, ::rlbot::api::GameTickPacket, ::rlbot::api::ControllerState>(
          std::mem_fn(&Bot::Service::GetControllerState), this)));
}

Bot::Service::~Service() {
}

::grpc::Status Bot::Service::GetControllerState(::grpc::ServerContext* context, const ::rlbot::api::GameTickPacket* request, ::rlbot::api::ControllerState* response) {
  (void) context;
  (void) request;
  (void) response;
  return ::grpc::Status(::grpc::StatusCode::UNIMPLEMENTED, "");
}


}  // namespace rlbot
}  // namespace api

