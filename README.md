# ip-checker

## Overview
This project is a solution for collecting statistics from a network of IP addresses, providing insights into ping performance, packet loss, and more. It demonstrates a minimalistic Ruby non-Rails tech stack and is containerized using Docker for easy setup.
## Tech Stack

- **Language**: Ruby
- **Framework**: Grape
- **Database**: PostgreSQL (with Timescale Hypertables), Redis
- **ORM**: Sequel
- **Testing**: RSpec
- **Containerization**: Docker

## How It Works

1. **Data Ingestion**: Periodically collects ping data, such as Round-Trip Time (RTT), packet loss status, timestamps, etc in background Sidekiq jobs.
2. **Data Processing**: Processes and stores data in PostgreSQL, utilizing hypertables index for efficient time-series management.
3. **Statistics Calculation**: Utilizes `QueryStatisticsService` for aggregating statistical information like average RTT, maximum/minimum RTT, median RTT, standard deviation of RTT, and loss percentage.
4. **API Exposure**

The API is designed to manage IP addresses, allowing enabling/disabling of statistics collection, retrieval of statistics, and deletion of IP addresses. It's built using the Grape framework.

### Endpoints

#### Add an IP address
- **Endpoint:** `POST /api/v1/ips`
- **Parameters:**
   - `ip` (String): IP Address (IPv4/IPv6)
   - `enabled` (Boolean): Enable flag
- **Response:** IP object

#### Enable statistics collection for IP
- **Endpoint:** `POST /api/v1/ips/:id/enable`
- **Response:** IP object

#### Disable statistics collection for IP
- **Endpoint:** `POST /api/v1/ips/:id/disable`
- **Response:** IP object

#### Get Statistics for the IP address
- **Endpoint:** `GET /api/v1/ips/:id/stats`
- **Parameters:**
   - `time_from` (DateTime): Start time for statistics
   - `time_to` (DateTime): End time for statistics
- **Response:** Statistics object

#### Delete IP address
- **Endpoint:** `DELETE /api/v1/ips/:id`
- **Response:** Success message

## Running the Project Using Docker

```
docker compose up
```

**Access the Application**:
   Open your browser or API client and navigate to `http://localhost:3000` endpoints.

## Testing

To run the tests, execute the following command inside the Docker container:

```shell
docker exec -it <container_id> rspec spec
```
