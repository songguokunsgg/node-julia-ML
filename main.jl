using JSON
using MbedTLS
using HTTP
using DataFrames
using CSV
using MLBase
using MLDataUtils

include("Servers/Classification/logistic.jl")
include("Servers/Classification/bayes.jl")
include("Servers/Classification/svm.jl")
include("Servers/utils.jl")

# 使用一个函数数组来统一索引所有的算法，避免大量的if else
const algorithms = Dict(
    "logistic" => Logistic.logistic_run,
    "bayes" => bayes.bayes_run,
    "svm" => svm.svm_run
)

function handle_request(req)

    # 设置CORS头
    cors_headers = [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type, Accept"
    ]

    # @info HTTP.method(req)
    # 处理预检请求
    if HTTP.method(req) == "OPTIONS"
        return HTTP.Response(204, cors_headers)

        # 处理POST请求
    elseif HTTP.method(req) == "POST"

        body_str = String(req.body)
        json_data = JSON.parse(body_str)
        @info json_data
        method = json_data["method"]

        # 将文件内容转换为DataFrame（这里假设内容是CSV格式的）
        file_content = json_data["csvContent"]
        df = CSV.File(IOBuffer(file_content)) |> DataFrame

        # 使用算法进行任务
        if method == "logistic"

            CA, MAE = algorithms[method](df, ratio=0.7, json_data=json_data)

        elseif method == "bayes"
            CA, MAE = algorithms[method](df, learning_rate)
        elseif method == "svm"
            CA, MAE = algorithms[method](df, learning_rate)
        end

        # 将返回的结果返回为json，以便处理
        result = Dict("CA" => CA, "MAE" => MAE)

        try
            return HTTP.Response(200, JSON.json(result))
        catch
            return HTTP.Response(204, cors_headers)
        end

    else
        # 处理 /*
        return static_file_router(req, cors_headers)
    end
end

function static_file_router(req, cors_headers)
    # 设置CORS头

    uri = HTTP.URI(req.target)
    path = uri.path

    if path == "/"
        html_content = read("webUI/main.html", String)
        return HTTP.Response(200, ["Content-Type" => "text/html"; cors_headers...], html_content)


    elseif occursin(".html", path)
        # 如果请求是一个HTML页面
        filepath = "webUI" * path  # 如果你的HTML文件在webUI文件夹里
        try
            file_content = read(filepath, String)
            return HTTP.Response(200, ["Content-Type" => "text/html"; cors_headers...], file_content)
        catch e
            return HTTP.Response(404, ["Content-Type" => "text/plain"; cors_headers...], "File Not Found")
        end

    elseif occursin("/static/", path)
        # 为其他静态文件，如CSS
        filepath = replace(path, "/static/" => "webUI/")
        try
            file_content = read(filepath, String)
            return HTTP.Response(200, ["Content-Type" => "text/css"; cors_headers...], file_content)
        catch e
            return HTTP.Response(404, ["Content-Type" => "text/plain"; cors_headers...], "404 File Not Found")
        end
    else
        return HTTP.Response(404, ["Content-Type" => "text/plain"; cors_headers...], "404 Not Found")
    end
end


# 开始监听
HTTP.serve(handle_request, "127.0.0.1", 9999)